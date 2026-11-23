Rails.application.routes.draw do
  mount RailsEventStore::Browser => '/res' if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "events#index"
  
  get '/sign-in', to: 'sessions#new'
  get '/sign-up', to: 'sessions#signup'
  
  resources :events, only: [:index, :show] do
    post :vote, on: :member
  end
end
