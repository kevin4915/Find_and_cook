class RecipesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = "Tu es un chef cuisinier. Propose une recette avec ces ingrédients..."

  def index
    @recipes = Recipe.all
  end

  def create
    @chat = Chat.create!(user: current_user, title: "Recherche du #{Time.now.strftime('%d/%m')}")
    @message = Message.new(chat: @chat, role: "user", content: params[:ingredients])
    @recipe = Recipe.create(title: "Recette du #{Time.now.strftime('%d/%m')}", ingredient: params[:ingredients], preparation: "en cours", rating: 0)
    if @message.save
      begin
        llm_chat = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)
        response = llm_chat.ask(@message.content)
        Message.create!(content: response.content, role: "assistant", chat: @chat)
      rescue RubyLLM::ConfigurationError
        Message.create!(content: "IA en attente de configuration.", role: "assistant", chat: @chat)
      end
      redirect_to recipes_path
    else
      redirect_to root_path
    end
  end
end
