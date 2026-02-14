Rails.application.routes.draw do
  get "login", to: "sessions#new"
  post "sessions", to: "sessions#create"
  delete "session", to: "sessions#destroy"

  resource :feed, only: [ :show ]
  resources :posts, only: [ :create ]
  resources :reactions, only: [ :create, :destroy ]

  get "up" => "rails/health#show", as: :rails_health_check
  root "feeds#show"
end
