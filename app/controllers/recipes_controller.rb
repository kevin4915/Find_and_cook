class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = Recipe.all
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
          preparation_time: data["duration"],
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
    session.delete(:pending_recipe_ids)
    session.delete(:recipe_index)
    redirect_to recipe_path(@recipe)
  end

  private

  def system_prompt
    prompt = "Tu es un chef cuisinier. Réponds UNIQUEMENT avec un tableau JSON de 5 recettes avec tous les ingrédients listés avec une URL
    d'image d'illustration de la recette, une description, une durée de préparation en minutes, et attribue un nombre entier en note sur 5
    à chaque recette, is_healthy, is_protein et is_gourmet. Le format de ta réponse doit être exactement celui-ci, sans texte autour, sans markdown.
  Format exact :
  [
    {
      \"title\": \"Nom de la recette\",
      \"ingredient\": \"liste des ingrédients\",
      \"preparation\": \"étapes de préparation\",
      \"image\": \"URL de l'image\",
      \"description\": \"description\",
      \"duration\": \"durée de préparation en minutes\",
      \"rating\": \"note sur 5\"
      \"is_healthy\": true,
      \"is_protein\": false,
      \"is_gourmet\": true
    }
  ]"

    if current_user.forbidden_ingredients.present?
      prompt += "\n\nATTENTION : Tu ne dois en aucun cas utiliser ces ingrédients : #{current_user.forbidden_ingredients}."
    end
  end
end
