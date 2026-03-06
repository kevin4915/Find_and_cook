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
    session[:last_image] = @recipe.image_URL
  end

  def next_recipe
    ids = session[:pending_recipe_ids]
    index = session[:recipe_index]
    @recipe = Recipe.find(ids[index])

    if @recipe.image_URL == session[:last_image] && Recipe::IMAGES.length > 1
      other_images = Recipe::IMAGES - [session[:last_image]]
      @recipe.update(image_URL: other_images.sample)
    end

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
    session.delete(:last_image)
    redirect_to recipe_path(@recipe)
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    if @recipe.destroy
      redirect_to recipes_path, notice: "Recette supprimée."
    else
      redirect_to recipes_path, status: :unprocessable_entity, alert: "Impossible de supprimer la recette."
    end
  end

  private

  def system_prompt
    prompt = "Tu es un chef cuisinier. Je suis une personne qui n'a pas d'idée pour cuisiner un plat avec ce qu'il
    me reste dans mon frigo. Réponds UNIQUEMENT avec un tableau JSON de 2 recettes. Elles doivent avoir un nom qui comporte le premier mot donné par l'utilisateur, la liste
    des ingrédients et leur quantité pour la préparer, la recette complète et détaillée avec le déroulé de plusieurs étapes, une courte description de maximum 10 mots, une durée de
    préparation en minutes, et attribue une note aléatoire entre 3 et 5 arrondis à l'inférieur.
    à chaque recette, is_healthy, is_protein et is_gourmet. Chaque élément de ta réponse doit impérativement être en français et
    le format de ta réponse doit être exactement celui-ci, sans texte autour, sans markdown.
  Format exact :
  [
    {
      \"title\": \"Nom de la recette\",
      \"ingredient\": \"ingrédient 1\\ningrédient 2\",
      \"preparation\": \"1. étape\\n2. étape\",
      \"short_description\": \"courte description\",
      \"preparation_time\": \"durée de préparation en minutes\",
      \"rating\": \"note sur 5\",
      \"is_healthy\": true,
      \"is_protein\": false,
      \"is_gourmet\": true
    }
  ]"

    if current_user.forbidden_ingredients.present?
      prompt << "\n\nATTENTION : Tu ne dois en aucun cas utiliser ces ingrédients : #{current_user.forbidden_ingredients}."
    end
  end
end
