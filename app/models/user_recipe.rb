class UserRecipe < ApplicationRecord
  belongs_to :user, foreign_key: :users_id
  belongs_to :recipe, foreign_key: :recipes_id
end
