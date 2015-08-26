class CreateBlockedUsers < ActiveRecord::Migration
  def change
    create_table :blocked_users do |t|
      t.integer :user_id, null: false
      t.integer :blocked_user_id, null: false
      t.timestamps
    end
  end
end
