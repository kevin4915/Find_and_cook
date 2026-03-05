class Recipe < ApplicationRecord
  has_many :user_recipe
  validates :title, :ingredient, :preparation, presence: true
  validates :rating, numericality: { only_integer: true }
end
