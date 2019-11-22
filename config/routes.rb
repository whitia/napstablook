Rails.application.routes.draw do
  root 'statics#index'
  get 'help', to: 'statics#help'
  get 'privacy', to: 'statics#privacy'
  resources :users do
    resources :funds do
      collection { post :import }
      collection { post :set_category }
      collection { post :set_increase }
      collection { post :set_ratio }
    end
  end
  resources :sessions
end
