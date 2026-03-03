class RecipesController < ApplicationController
  SYSTEM_PROMPT = "Tu es un chef cuisinier.
    J'ai des ingrédients dans mon frigo mais je ne sais pas quoi préparer.
    Réponds moi avec un nom de recette, ses ingrédients et les étapes de préparation"

  def create
    @chat = current_user.chats.first_or_create!(title: "Nouvelle recherche")

    @message = Message.new
    @message.chat = @chat
    @message.role = "user"
    @message.content = params[:ingredients]

    if @message.save
      llm_chat = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)

      response = llm_chat.ask(@message.content)

      Message.create(content: response.content, role: "assistant", chat: @chat)

      redirect_to swipe_recipes_path
    else
      redirect_to root_path
    end
  end
end
