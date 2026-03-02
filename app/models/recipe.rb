class Recipe < ApplicationRecord
  has_many :users_recipes
  validates :title, :ingredient, :preparation, presence: true
  validates :rating, numericality: { only_integer: true }
end
