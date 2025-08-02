module Notyfhir
  class Configuration
    attr_accessor :vapid_public_key, :vapid_private_key, :vapid_subject
    attr_accessor :user_class_name, :current_user_method
    attr_accessor :notification_icon, :notification_badge
    attr_accessor :service_worker_path
    
    def initialize
      @user_class_name = "User"
      @current_user_method = :current_user
      @notification_icon = "/icon-192.png"
      @notification_badge = "/icon-192.png"
      @service_worker_path = "/service-worker"
      @vapid_subject = "mailto:admin@example.com"
    end
    
    def user_class
      @user_class_name.constantize
    end
  end
end