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
  get '/funds/set_category', to: 'funds#set_category'
  get '/funds/set_ratio', to: 'funds#set_ratio'
end
