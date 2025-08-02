class CreateNotyfhirNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notyfhir_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.json :data
      t.datetime :read_at
      
      t.timestamps
    end
    
    add_index :notyfhir_notifications, :read_at
    add_index :notyfhir_notifications, [:user_id, :read_at]
    add_index :notyfhir_notifications, [:user_id, :created_at]
  end
end