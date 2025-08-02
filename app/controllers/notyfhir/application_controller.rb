module Notyfhir
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    
    private
    
    def current_user
      send(Notyfhir.configuration.current_user_method)
    end
  end
end