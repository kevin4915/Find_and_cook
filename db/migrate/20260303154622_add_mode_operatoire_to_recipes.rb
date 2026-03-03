class AddModeOperatoireToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :mode_operatoire, :text
  end
end
