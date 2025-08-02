require 'web_push'

module Notyfhir
  class WebPushService
    def self.send_notification(user, title:, body:, icon: nil, badge: nil, data: {})
      # 建立通知記錄
      notification = user.notyfhir_notifications.create!(
        title: title,
        body: body,
        data: data
      )
      
      # 取得使用者的未讀通知數量
      unread_count = user.notyfhir_notifications.unread.count
      
      # 準備推播訊息，包含通知 ID 和路徑
      message = {
        title: title,
        options: {
          body: body,
          icon: icon || Notyfhir.configuration.notification_icon,
          badge: badge || Notyfhir.configuration.notification_badge,
          data: data.merge({
            notification_id: notification.id,
            path: "/notyfhir/notifications/#{notification.id}",
            badge_count: unread_count
          })
        }
      }
      
      Rails.logger.info "Sending push notification to user #{user.id}"
      Rails.logger.info "Message: #{message.inspect}"
      Rails.logger.info "Push subscriptions count: #{user.notyfhir_push_subscriptions.count}"
      
      user.notyfhir_push_subscriptions.find_each do |subscription|
        begin
          Rails.logger.info "Sending to endpoint: #{subscription.endpoint}"
          
          response = WebPush.payload_send(
            message: message.to_json,
            endpoint: subscription.endpoint,
            p256dh: subscription.p256dh,
            auth: subscription.auth,
            vapid: {
              public_key: Notyfhir.configuration.vapid_public_key,
              private_key: Notyfhir.configuration.vapid_private_key,
              subject: Notyfhir.configuration.vapid_subject
            }
          )
          
          Rails.logger.info "Push notification sent successfully: #{response.inspect}"
        rescue WebPush::ExpiredSubscription
          Rails.logger.warn "Expired subscription removed"
          subscription.destroy
        rescue => e
          Rails.logger.error "Failed to send push notification: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          
          # 如果是無效的訂閱，刪除它
          if e.message.include?("410") || e.message.include?("404")
            subscription.destroy
          end
        end
      end
      
      notification
    end
    
    def self.generate_vapid_keys
      vapid_key = WebPush.generate_key
      {
        public_key: vapid_key.public_key,
        private_key: vapid_key.private_key
      }
    end
  end
end