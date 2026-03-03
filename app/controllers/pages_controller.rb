class PagesController < ApplicationController
  def index
    return unless user_signed_in?

    chats = current_user.chats.order(created_at: :desc)
    @chat = chats.first_or_create!(title: "Nouvelle recherche")
    @messages = @chat.messages.order(created_at: :asc)
  end
end
