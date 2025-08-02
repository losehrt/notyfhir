require_dependency "notyfhir/application_controller"

module Notyfhir
  class NotificationSettingsController < ApplicationController
    before_action :authenticate_user!
    
    def index
      @push_subscriptions = current_user.notyfhir_push_subscriptions
      @vapid_public_key = Notyfhir.configuration.vapid_public_key
    end
    
    def test
      WebPushService.send_notification(
        current_user,
        title: "測試通知",
        body: "這是一個測試通知訊息 #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
      )
      
      redirect_to notification_settings_path, notice: "測試通知已發送"
    end
    
    private
    
    def authenticate_user!
      unless current_user
        redirect_to main_app.root_path, alert: "請先登入"
      end
    end
  end
end