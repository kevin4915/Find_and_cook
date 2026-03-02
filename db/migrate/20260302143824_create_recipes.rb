class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :ingredient
      t.text :preparation
      t.text :comment
      t.integer :rating
      t.timestamps
    end
  end
end
