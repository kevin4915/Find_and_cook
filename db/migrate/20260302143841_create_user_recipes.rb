class CreateUserRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :user_recipes do |t|
      t.references :users, null: false, foreign_key: true
      t.references :recipes, null: false, foreign_key: true
      t.timestamps
    end
  end
end
