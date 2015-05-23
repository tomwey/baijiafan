Rails.application.routes.draw do
  
  require 'api_v1'
  
  root 'home#index'
  
  resources :items
  resources :users
  resources :orders
  resources :order_state_logs
  
  mount API::APIV1 => '/'
  
end
