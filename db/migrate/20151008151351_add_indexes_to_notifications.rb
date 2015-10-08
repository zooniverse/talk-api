class AddIndexesToNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, [:user_id, :created_at]
    add_index :notifications, [:user_id, :section, :created_at]
  end
end
