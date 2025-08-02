module Notyfhir
  class Configuration
    attr_accessor :vapid_public_key, :vapid_private_key, :vapid_subject
    attr_accessor :user_class_name, :current_user_method
    attr_accessor :notification_icon, :notification_badge
    attr_accessor :service_worker_path
    
    # PWA configuration
    attr_accessor :pwa_enabled, :app_name, :app_short_name, :app_description
    attr_accessor :app_theme_color, :app_background_color, :app_display
    attr_accessor :app_start_url, :app_scope
    
    def initialize
      @user_class_name = "User"
      @current_user_method = :current_user
      @notification_icon = "/icon-192.png"
      @notification_badge = "/icon-192.png"
      @service_worker_path = "/service-worker"
      @vapid_subject = "mailto:admin@example.com"
      
      # PWA defaults
      @pwa_enabled = false
      @app_name = nil
      @app_short_name = nil
      @app_description = nil
      @app_theme_color = "#000000"
      @app_background_color = "#ffffff"
      @app_display = "standalone"
      @app_start_url = "/"
      @app_scope = "/"
    end
    
    def user_class
      @user_class_name.constantize
    end
  end
end