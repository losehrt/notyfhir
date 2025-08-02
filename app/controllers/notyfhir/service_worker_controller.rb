module Notyfhir
  class ServiceWorkerController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def show
      render file: Notyfhir::Engine.root.join("app/javascript/notyfhir/service-worker.js"),
             content_type: "application/javascript"
    end
  end
end