# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "bin/rails routes".
  root to: "main#index"

  resources :teachers do
    member do
      post :resend_welcome_email
      post :validate
      post :deny
    end
    collection { post :import }
  end
  resources :schools
  resources :pages, param: :url_slug
  resources :email_templates, only: [:index, :update, :edit]

  # The line below would be unnecessary since we use Google.
  # sessions#new could be left as an empty Ruby function.
  # We just need to define a "new" view to prompt for user name,
  # and password.
  get    "/login",  to: "sessions#new",     as: "login"
  delete "/logout", to: "sessions#destroy", as: "logout"

  get "/auth/:provider/callback", to: "sessions#omniauth_callback"
  post "/auth/:provider/callback", to: "sessions#omniauth_callback"

  get "/dashboard", to: "main#dashboard", as: "dashboard"
end
