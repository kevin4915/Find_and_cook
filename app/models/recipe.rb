class Recipe < ApplicationRecord
  has_many :user_recipes, dependent: :destroy, foreign_key: :recipes_id
  validates :title, :ingredient, :preparation, presence: true
  validates :rating, numericality: { only_integer: true }

  IMAGES = [
    "recipes_pictures/poulet.jpg",
    "recipes_pictures/poulet1.jpg",
    "recipes_pictures/poulet2.jpg",
    "recipes_pictures/poulet3.jpg",
    "recipes_pictures/poulet4.jpg",
    "recipes_pictures/poulet5.jpg",
    "recipes_pictures/poulet6.jpg",
    "recipes_pictures/poulet7.jpg",
    "recipes_pictures/poulet8.jpg",
    "recipes_pictures/chocolat.jpg",
    "recipes_pictures/chocolat1.jpg",
    "recipes_pictures/chocolat2.jpg",
    "recipes_pictures/chocolat3.jpg",
    "recipes_pictures/chocolat4.jpg",
    "recipes_pictures/chocolat5.jpg",
    "recipes_pictures/tomate.jpg",
    "recipes_pictures/tomate1.jpg",
    "recipes_pictures/tomate2.jpg",
    "recipes_pictures/tomate3.jpg",
    "recipes_pictures/tomate4.jpg",
    "recipes_pictures/tomate5.jpg",
    "recipes_pictures/boeuf.jpg",
    "recipes_pictures/boeuf1.jpg",
    "recipes_pictures/boeuf2.jpg",
    "recipes_pictures/boeuf3.jpg",
    "recipes_pictures/boeuf4.jpg",
    "recipes_pictures/oeuf.jpg",
    "recipes_pictures/oeuf1.jpg",
    "recipes_pictures/oeuf2.jpg",
    "recipes_pictures/oeuf3.jpg",
    "recipes_pictures/oeuf4.jpg",
  ].freeze

  DEFAULT_IMAGE = "recipes_pictures/default.jpg".freeze

  before_create :assign_smart_image

  private

  def assign_smart_image
    return unless image_URL.blank?

    recipe_words = "#{title} #{short_description}".downcase.split(/\W+/)

    matched_images = IMAGES.select do |img|
      img_words = File.basename(img, ".*").downcase.gsub(/\d+/, "").split("_")
      img_words.any? do |img_word|
        recipe_words.any? do |recipe_word|
          img_word.start_with?(recipe_word) || recipe_word.start_with?(img_word)
        end
      end
    end

    self.image_URL = matched_images.any? ? matched_images.sample : DEFAULT_IMAGE
  end
end
