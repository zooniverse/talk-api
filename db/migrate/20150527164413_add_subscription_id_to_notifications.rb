class AddSubscriptionIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :subscription_id, :integer, null: false
    add_index :notifications, [:subscription_id]
  end
end
