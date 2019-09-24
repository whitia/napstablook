Rails.application.routes.draw do
  root 'statics#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    resources :funds do
      collection { post :import }
    end
  end
end