Rails.application.routes.draw do
  devise_for :users
  root to: "pages#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :recipes, only: [:index, :show, :create] do
    resources :user_recipes, only: [:create]
    resources :chats, only: [:create, :show]
  end
end
