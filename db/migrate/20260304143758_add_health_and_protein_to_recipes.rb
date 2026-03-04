class AddHealthAndProteinToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :is_healthy, :boolean
    add_column :recipes, :is_protein, :boolean
  end
end
