module Notyfhir
  class PushSubscription < ApplicationRecord
    self.table_name = "notyfhir_push_subscriptions"
    
    belongs_to :user, class_name: Notyfhir.configuration.user_class_name
    
    validates :endpoint, presence: true, uniqueness: true
    validates :p256dh, presence: true
    validates :auth, presence: true
    
    before_validation :set_device_info, on: :create
    
    private
    
    def set_device_info
      self.device_name ||= "Unknown Device"
      self.device_type ||= "Unknown"
      self.browser ||= "Unknown"
      self.operating_system ||= "Unknown"
    end
  end
end