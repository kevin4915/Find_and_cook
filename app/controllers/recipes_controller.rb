class RecipesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = "Tu es un chef cuisinier. Réponds UNIQUEMENT avec un tableau JSON de 5 recettes avec tous les ingrédients listés avec une URL
  d'image d'illustration de la recette, une courte description en 10 mots, une durée de préparation en minutes, et attribue un nombre entier en note sur 5
  à chaque recette. Le format de ta réponse doit être exactement celui-ci, sans texte autour, sans markdown.
  Format exact :
  [
    {
      \"title\": \"Nom de la recette\",
      \"ingredient\": \"liste des ingrédients\",
      \"preparation\": \"étapes de préparation\",
      \"image\": \"URL de l'image\",
      \"description\": \"courte description\",
      \"duration\": \"durée de préparation en minutes\",
      \"rating\": \"note sur 5\"
    }
  ]"

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
      llm_chat = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)
      response = llm_chat.ask(@message.content)
      Message.create!(content: response.content, role: "assistant", chat: @chat)

      recipes_data = JSON.parse(response.content)
      recipe_ids = recipes_data.map do |recipe_data|
        Recipe.create!(
          title: recipe_data["title"],
          ingredient: recipe_data["ingredient"],
          preparation: recipe_data["preparation"],
          rating: recipe_data["rating"],
          image_URL: recipe_data["image"],
          short_description: recipe_data["description"],
          preparation_time: recipe_data["duration"]
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
    index = session[:recipe_index]

    redirect_to root_path and return if ids.nil? || index >= ids.length

    @recipe = Recipe.find(ids[index])
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
end
