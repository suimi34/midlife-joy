Rails.application.routes.draw do
  root "home#index"

  get "login", to: "sessions#new"
  post "sessions", to: "sessions#create"
  delete "session", to: "sessions#destroy"

  resource :feed, only: [ :show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
