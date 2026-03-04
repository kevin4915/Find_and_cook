Rails.application.routes.draw do
  devise_for :users
  root to: "pages#index"

  get  "swipe",       to: "recipes#swipe",      as: :swipe
  post "next_recipe", to: "recipes#next_recipe", as: :next_recipe
  post "save_recipe", to: "recipes#save_recipe", as: :save_recipe

  resources :recipes, only: [:index, :show, :create] do
    resources :user_recipes, only: [:create]
    resources :chats, only: [:create, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
