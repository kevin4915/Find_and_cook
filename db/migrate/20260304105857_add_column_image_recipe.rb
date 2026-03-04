class AddColumnImageRecipe < ActiveRecord::Migration[8.1]
  def change
        add_column :recipes, :image_URL, :string
  end
end
