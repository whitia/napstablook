Rails.application.routes.draw do
  root 'statics#index'
  get '/terms', to: 'statics#terms'
  get '/privacy', to: 'statics#privacy'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  
  get '/signin', to: 'session#new'
  post '/signin', to: 'session#create'
  delete '/signout', to: 'session#destroy'

  get '/funds', to: 'funds#index'
  post '/funds/import', to: 'funds#import'
  post '/funds/set_category', to: 'funds#set_category'
  post '/funds/set_increase', to: 'funds#set_increase'
  post '/funds/set_ideal', to: 'funds#set_ideal'
end
