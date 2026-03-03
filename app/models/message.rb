class Message < ApplicationRecord
  belongs_to :chat, foreign_key: "chats_id"
  validates :role, :content, presence: true
end
