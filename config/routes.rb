Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  match "*path", to: "application#options", via: :options
  namespace :api do
    namespace :v1 do
      resources :alumn_guardians
      resources :alumns do
        put "associate", on: :member
        get "birthdays_by_month", on: :collection
      end
      resources :assistances
      resources :classrooms
      resources :disciplines
      resources :guardians do
        put "associate", on: :member
      end
      resources :lessons
      resources :orders
      resources :payments
      resources :plan_disciplines
      resources :plans
      resources :products
      resources :subscription_payments
      resources :subscriptions do
        member do
          put :rehabilitate
        end
      end
      resources :user_disciplines
      resources :users
      # post "/auth/login", to: "authentication#login"
      # config/routes.rb
      post "auth/login", to: "auth#login"
      post "auth/logout", to: "auth#logout"
      get "auth/me", to: "auth#me"
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
