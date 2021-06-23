Rails.application.routes.draw do
  resources :connections
  get 'api/connections', to: 'connection#action' 
  post 'api/connections', to: 'connection#store'
  get 'api/users', to: 'user#index'
  post 'api/users', to: 'user#store'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
