class Chat < ApplicationRecord
  belongs_to :user, foreign_key: "users_id", optional: true
  has_many :messages, foreign_key: "chats_id"
end
