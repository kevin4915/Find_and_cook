class RecipesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = "Tu es un chef cuisinier. Réponds UNIQUEMENT avec un tableau JSON de 5 recettes.
  Pour chaque recette, inclus : titre, ingrédients, préparation, une note entière sur 5, durée en minutes (duration),
  is_healthy (boolean), et is_protein (boolean).
  Format exact :
  [
    {
      \"title\": \"Nom\",
      \"ingredient\": \"liste\",
      \"preparation\": \"étapes\",
      \"rating\": 5,
      \"duration\": 25,
      \"is_healthy\": true,
      \"is_protein\": false
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

      recipes_data = JSON.parse(response.content)
      recipe_ids = recipes_data.map do |data|
        Recipe.create!(
          title: data["title"],
          ingredient: data["ingredient"],
          preparation: data["preparation"],
          rating: data["rating"],
          preparation_time: data["duration"],
          is_healthy: data["is_healthy"],
          is_protein: data["is_protein"]
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
end
