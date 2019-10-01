Rails.application.routes.draw do
  root 'statics#index'
  get '/help', to: 'statics#help'
  get '/signin', to: 'sessions#new'
  post '/signin', to: 'sessions#create'
  delete '/signout', to: 'sessions#destroy'
  resources :users, :except => :new do
    resources :funds do
      collection { post :import }
      collection { post :set_category }
      collection { post :set_increase }
      collection { post :set_ratio }
    end
  end
  get '/signup', to: 'users#new'
end
