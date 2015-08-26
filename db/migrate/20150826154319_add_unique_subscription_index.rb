class AddUniqueSubscriptionIndex < ActiveRecord::Migration
  def change
    add_index :subscriptions, [:user_id, :source_id, :source_type, :category], unique: true, name: 'index_subscriptions_uniquely'
  end
end
