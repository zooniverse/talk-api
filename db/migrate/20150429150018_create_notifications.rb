class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.text :message, null: false
      t.string :url, null: false
      t.string :section, null: false
      t.boolean :delivered, default: false, null: false
      t.timestamps
    end
    
    add_index :notifications, [:user_id, :section, :delivered, :created_at], name: 'unread_section_index'
    add_index :notifications, [:user_id, :delivered, :created_at], name: 'unread_index'
    add_index :notifications, :created_at, name: 'expiring_index'
  end
end
