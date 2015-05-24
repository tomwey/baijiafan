Rails.application.routes.draw do
  
  require 'api_v1'
  
  root 'home#index'
  
  resources :items
  resources :users do
    member do
      patch :block
      patch :unblock
    end
  end
  resources :orders
  resources :order_state_logs
  
  mount API::APIV1 => '/'
  
end
