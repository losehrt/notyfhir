require_dependency "notyfhir/application_controller"

module Notyfhir
  class PushSubscriptionsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: [:create, :destroy]
    
    def create
      subscription = current_user.notyfhir_push_subscriptions.find_or_initialize_by(
        endpoint: params[:endpoint]
      )
      
      subscription.assign_attributes(
        p256dh: params[:keys][:p256dh],
        auth: params[:keys][:auth],
        user_agent: request.user_agent,
        device_info: detect_device_info
      )
      
      if subscription.save
        render json: { status: 'ok' }
      else
        render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def destroy
      subscription = current_user.notyfhir_push_subscriptions.find_by(endpoint: params[:endpoint])
      
      if subscription&.destroy
        head :ok
      else
        head :not_found
      end
    end
    
    private
    
    def detect_device_info
      user_agent = request.user_agent || ""
      
      device_type = case user_agent
      when /iPhone/i
        "iPhone"
      when /iPad/i
        "iPad"
      when /Android/i
        "Android"
      when /Windows Phone/i
        "Windows Phone"
      else
        "Desktop"
      end
      
      browser = case user_agent
      when /Chrome/i
        "Chrome"
      when /Safari/i
        "Safari"
      when /Firefox/i
        "Firefox"
      when /Edge/i
        "Edge"
      else
        "Other"
      end
      
      os = case user_agent
      when /iPhone OS (\d+)/i
        "iOS #{$1}"
      when /Android (\d+)/i
        "Android #{$1}"
      when /Windows NT/i
        "Windows"
      when /Mac OS X/i
        "macOS"
      else
        "Unknown"
      end
      
      device_name = "#{browser} on #{os}"
      
      {
        device_type: device_type,
        browser: browser,
        operating_system: os,
        device_name: device_name
      }
    end
    
    def authenticate_user!
      unless current_user
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end