class AddColumnRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :short_description, :string
    add_column :recipes, :preparation_time, :integer
  end
end
