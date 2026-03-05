class AddIsGourmetToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :is_gourmet, :boolean
  end
end
