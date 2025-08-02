module Notyfhir
  class Notification < ApplicationRecord
    self.table_name = "notyfhir_notifications"
    
    belongs_to :user, class_name: Notyfhir.configuration.user_class_name
    
    validates :title, presence: true
    validates :body, presence: true
    
    scope :unread, -> { where(read_at: nil) }
    scope :read, -> { where.not(read_at: nil) }
    scope :recent, -> { order(created_at: :desc) }
    
    def read?
      read_at.present?
    end
    
    def unread?
      read_at.nil?
    end
    
    def mark_as_read!
      update!(read_at: Time.current) if unread?
    end
  end
end