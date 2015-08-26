class IndexBlockedUsers < ActiveRecord::Migration
  def change
    add_index :blocked_users, [:user_id, :blocked_user_id], unique: true
  end
end
