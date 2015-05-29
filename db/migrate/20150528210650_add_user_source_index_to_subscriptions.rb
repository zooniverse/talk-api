class AddUserSourceIndexToSubscriptions < ActiveRecord::Migration
  def change
    add_index :subscriptions, [:user_id, :source_id, :source_type]
  end
end
