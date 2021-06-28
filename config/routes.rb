Rails.application.routes.draw do
  get 'api/connections', to: 'connection#index' 
  post 'api/connections', to: 'connection#store'
  get 'api/connection-between', to: 'connection#connectionBetween'

  get 'api/users', to: 'user#index'
  post 'api/users', to: 'user#store'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
