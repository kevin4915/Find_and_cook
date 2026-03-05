class Recipe < ApplicationRecord
  has_many :user_recipes, foreign_key: :recipes_id
  validates :title, :ingredient, :preparation, presence: true
  validates :rating, numericality: { only_integer: true }
end
