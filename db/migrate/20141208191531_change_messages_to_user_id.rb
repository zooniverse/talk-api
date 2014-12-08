class ChangeMessagesToUserId < ActiveRecord::Migration
  def change
    remove_column :messages, :sender_id
    remove_column :messages, :recipient_id
    add_column :messages, :user_id, :integer, null: false
  end
end
