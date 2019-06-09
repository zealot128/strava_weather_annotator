Rails.application.routes.draw do
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  get '/about' => "pages#about"

  resource :user, only: [:edit, :update], controller: :user
  get 'user/preview' => 'user#preview'

  resources :trips, only: [:index, :show] do
    collection do
      post :refresh
      get :heatmap
    end
    member do
      get :gpx
      post :weather
    end
    get 'comment/new' => 'comments#new'
    post 'comment' => 'comments#create', as: :comment_create
  end
  root to: 'pages#index'
end
