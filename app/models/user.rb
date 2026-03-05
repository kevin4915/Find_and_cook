class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :user_recipes, dependent: :destroy
  has_many :recipes, through: :users_recipes
  has_many :chats, foreign_key: "users_id", dependent: :destroy
  validates :email, uniqueness: true, presence: true
  validates :first_name, :last_name, presence: true
end
