Rails.application.routes.draw do
  root 'statics#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    resources :funds do
      collection { post :import }
      collection { post :set_category }
      collection { post :set_increase }
      collection { post :set_ratio }
    end
  end
end
