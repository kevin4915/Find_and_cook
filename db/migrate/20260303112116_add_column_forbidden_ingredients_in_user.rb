class AddColumnForbiddenIngredientsInUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :forbidden_ingredients, :string
  end
end
