class CreateNotyfhirPushSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :notyfhir_push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false
      t.text :user_agent
      t.json :device_info
      t.string :device_name
      t.string :device_type
      t.string :browser
      t.string :operating_system
      
      t.timestamps
    end
    
    add_index :notyfhir_push_subscriptions, :endpoint, unique: true
    add_index :notyfhir_push_subscriptions, [:user_id, :endpoint]
  end
end