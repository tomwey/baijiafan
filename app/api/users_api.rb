# coding: utf-8
require "rest_client"

module API
  class UsersAPI < Grape::API
    
    resource :users do
      
      get do
        { foo: 'bar' }
      end
      
    end # end users resource
    
  end
end