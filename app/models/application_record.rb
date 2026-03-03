class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  has_many :chats, foreign_key: "users_id"
end
