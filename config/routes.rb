Rails.application.routes.draw do
  get 'users/new'
  resources :users
end
