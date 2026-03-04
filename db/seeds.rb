# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   ends
puts "Nettoyage de la base..."
Recipe.destroy_all

puts "Création des recettes..."
Recipe.create!(
  title: "Poulet Rôti aux Herbes",
  ingredient: "1 poulet entier, herbes de Provence, huile d'olive, sel, poivre",
  preparation: "Préchauffer le four à 180°C. Masser le poulet avec l'huile et les herbes. Cuire 1h30.",
  rating: 5
)

Recipe.create!(
  title: "Pâtes à la Carbonara",
  ingredient: "Pâtes, guanciale, œufs, pecorino romano, poivre",
  preparation: "Cuire les pâtes. Faire revenir le guanciale. Mélanger œufs et fromage. Mélanger le tout hors du feu.",
  rating: 4
)

puts "Terminé ! #{Recipe.count} recettes créées."
