class RecipesController < ApplicationController
  SYSTEM_PROMPT = "
    Tu es un chef cuisinier professionnel.
    Génère une recette réalisable immédiatement à partir d’ingrédients.
    Réponds toujours dans ce format strict :

    Titre: <titre court>

    Ingrédients:
    - <liste réécrite proprement>

    Mode opératoire:
    1. <étape 1>
    2. <étape 2>
    3. <étape 3>

    Ne mets rien d’autre en dehors de ce format.
  "

  def index
    @recipes = Recipe.order(created_at: :desc)
  end

  def new
    @recipe = Recipe.new
  end

  def create
    ingredients = params[:recipe][:ingredient]

    user_prompt = "Voici mes ingrédients : #{ingredients}. Génère une recette complète."

    ruby_llm = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)
    response = ruby_llm.ask(user_prompt)
    generated = response.content

    title = generated.match(/Titre:\s*(.*)/)&.captures&.first&.strip || "Recette générée"
    ingredients_clean = generated.match(/Ingrédients:\s*([\s\S]*?)Mode opératoire:/)&.captures&.first&.strip || ingredients
    steps_clean = generated.match(/Mode opératoire:\s*([\s\S]*)/)&.captures&.first&.strip || "Étapes non trouvées"

    @recipe = Recipe.new(
      title: title,
      ingredient: ingredients_clean,
      preparation: steps_clean,
      rating: rand(1..5)
    )

    if @recipe.save
      redirect_to @recipe
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :rating,
      :ingredient,
      :preparation
    )
  end
end
