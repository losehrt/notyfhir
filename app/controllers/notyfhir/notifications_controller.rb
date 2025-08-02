require_dependency "notyfhir/application_controller"

module Notyfhir
  class NotificationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_notification, only: [:show, :mark_as_read]
    
    def index
      @notifications = current_user.notyfhir_notifications.recent
      @unread_count = current_user.notyfhir_notifications.unread.count
      update_app_badge
    end
    
    def show
      @notification.mark_as_read!
      update_app_badge
    end
    
    def mark_as_read
      @notification.mark_as_read!
      
      respond_to do |format|
        format.html { redirect_to notifications_path }
        format.turbo_stream
      end
    end
    
    def mark_all_as_read
      current_user.notyfhir_notifications.unread.update_all(read_at: Time.current)
      
      respond_to do |format|
        format.html { redirect_to notifications_path, notice: "所有通知已標記為已讀" }
        format.turbo_stream
      end
    end
    
    private
    
    def set_notification
      @notification = current_user.notyfhir_notifications.find(params[:id])
    end
    
    def update_app_badge
      # 通知前端更新 badge 數字
      unread_count = current_user.notyfhir_notifications.unread.count
      # 暫時先不使用 Turbo Streams broadcasting，避免 cable 設定問題
    end
    
    def authenticate_user!
      unless current_user
        redirect_to main_app.root_path, alert: "請先登入"
      end
    end
  end
end