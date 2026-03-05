Rails.application.routes.draw do
  #get "recipes/index"
  #get "recipes/show"
  #get "recipes/new"
  #get "recipes/edit"
  devise_for :users
  root to: "pages#index"

  get  "swipe",       to: "recipes#swipe",      as: :swipe
  post "next_recipe", to: "recipes#next_recipe", as: :next_recipe
  post "save_recipe", to: "recipes#save_recipe", as: :save_recipe

  resources :recipes, only: [:index, :show, :create, :destroy] do
    resources :user_recipes, only: [:create]
    resources :chats, only: [:create, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "images/random", to: "images#random"
end
