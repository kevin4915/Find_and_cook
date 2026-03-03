class UserRecipesController < ApplicationController
  def create
    @recipe = Recipe.find(params[:recipe_id])
    @user_recipe = UserRecipe.new(user: current_user, recipe: @recipe)

    if @user_recipe.save
      redirect_to recipes_path, notice: "Recette ajoutée à tes favoris !"
    else
      redirect_to recipes_path, alert: "Erreur lors de l'ajout."
    end
  end
end
