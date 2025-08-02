Notyfhir.configure do |config|
  # VAPID keys for Web Push
  # Generate with: rails generate notyfhir:vapid_keys
  config.vapid_public_key = ENV.fetch("VAPID_PUBLIC_KEY", Rails.application.credentials.dig(:vapid, :public_key))
  config.vapid_private_key = ENV.fetch("VAPID_PRIVATE_KEY", Rails.application.credentials.dig(:vapid, :private_key))
  config.vapid_subject = ENV.fetch("VAPID_SUBJECT", "mailto:admin@example.com")
  
  # User configuration
  config.user_class_name = "User"
  config.current_user_method = :current_user
  
  # Notification icons
  config.notification_icon = "/icon-192.png"
  config.notification_badge = "/icon-192.png"
  
  # Service Worker path
  config.service_worker_path = "/service-worker"
end