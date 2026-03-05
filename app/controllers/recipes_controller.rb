class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = Recipe.order(rating: :desc)
    recipe_ids = UserRecipe.where(users_id: current_user.id).pluck(:recipes_id)
    @recipes = Recipe.where(id: recipe_ids)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def create
    @chat = Chat.create!(user: current_user, title: "Recherche du #{Time.now.strftime('%d/%m')}")
    @message = Message.new(chat: @chat, role: "user", content: params[:ingredients])

    if @message.save
      llm_chat = RubyLLM.chat.with_instructions(system_prompt)
      response = llm_chat.ask(@message.content)

      recipes_data = JSON.parse(response.content)
      recipe_ids = recipes_data.map do |data|
        Recipe.create!(
          title: data["title"],
          ingredient: data["ingredient"],
          preparation: data["preparation"],
          rating: data["rating"],
          short_description: data["short_description"],
          preparation_time: data["preparation_time"],
          is_healthy: data["is_healthy"],

          is_protein: data["is_protein"],
          is_gourmet: data["is_gourmet"],
          short_description: data["description"]
        ).id
      end

      session[:pending_recipe_ids] = recipe_ids
      session[:recipe_index] = 0
      redirect_to swipe_path
    else
      redirect_to root_path
    end
  end

  def swipe
    ids = session[:pending_recipe_ids]
    @index = session[:recipe_index] || 0
    @total = ids&.length || 1

    redirect_to root_path and return if ids.nil? || @index >= ids.length

    @recipe = Recipe.find(ids[@index])
  end

  def next_recipe
    session[:recipe_index] += 1
    redirect_to swipe_path
  end

  def save_recipe
    ids = session[:pending_recipe_ids]
    index = session[:recipe_index]
    @recipe = Recipe.find(ids[index])
    UserRecipe.create!(users_id: current_user.id, recipes_id: @recipe.id)
    session.delete(:pending_recipe_ids)
    session.delete(:recipe_index)
    redirect_to recipe_path(@recipe)
  end

  private

  def system_prompt

    prompt = "Tu es un chef cuisinier. Je suis une personne qui n'a pas d'idée pour cuisiner un plat avec ce qu'il me
    reste dans mon frigo. Réponds UNIQUEMENT avec un tableau JSON de 2 recettes. Elles doivent avoir un nom, la liste des
    ingrédients pour la préparer, la recette complète et détaillée avec le déroulé de plusieurs étapes numérotées précédées de ***
    avec des retours à la ligne entre chaque étape, une durée de
    préparation en minutes, et attribue une note aléatoire entre 3 et 5 arrondis à l'inférieur.
    à chaque recette, is_healthy, is_protein et is_gourmet. Chaque élément de ta réponse doit impérativement être en français et
    le format de ta réponse doit être exactement celui-ci, sans texte autour, sans markdown.
  Format exact :
  [
    {
      \"title\": \"Nom de la recette\",
      \"ingredient\": \"liste des ingrédients\",
      \"preparation\": \"la recette complète et détaillée avec le déroulé en plusieurs étapes numérotées précédées de *** avec des retours à la ligne entre chaque étape\",
      \"short_description\": \"courte description\",
      \"preparation_time\": \"durée de préparation en minutes\",
      \"rating\": \"note sur 5\",
      \"is_healthy\": true,
      \"is_protein\": false,
      \"is_gourmet\": true
    }
  ]"

    return unless current_user.forbidden_ingredients.present?

    prompt += "\n\nATTENTION : Tu ne dois en aucun cas utiliser ces ingrédients : #{current_user.forbidden_ingredients}."
  end

  # def fetch_image(title)
  #   image = RubyLLM.paint("Photo réaliste d'un plat cuisiné : #{title}", model: "dall-e-3")
  #   image.url
  # rescue RubyLLM::Error
  #   "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
  # end
end
