Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      resources :alumn_guardians
      resources :alumns
      resources :assistances
      resources :classrooms
      resources :disciplines
      resources :guardians
      resources :lessons
      resources :orders
      resources :payments
      resources :plan_disciplines
      resources :plans
      resources :products
      resources :subscription_payments
      resources :subscriptions
      resources :user_disciplines
      resources :users
      # post "/auth/login", to: "authentication#login"
      # config/routes.rb
      post "auth/login", to: "auth#login"
      get "profile", to: "api#profile"  # Protected endpoint
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
