Rails.application.routes.draw do
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  resources :trips, only: [:index, :show] do
    collection do
      post :refresh
    end
  end
  root to: 'pages#index'
end
