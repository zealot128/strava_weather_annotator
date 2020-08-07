Rails.application.routes.draw do
  post '/auth/developer/callback' => 'sessions#backdoor'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  get '/about' => "pages#about"

  resource :user, only: [:edit, :update], controller: :user do
    resource :webhook, only: [:create, :destroy], controller: 'user_webhooks'
  end
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
  get 'webhook/:user_id' => 'webhook#challenge', as: :webhook
  post 'webhook/:user_id' => 'webhook#callback'
  root to: 'pages#index'
end
