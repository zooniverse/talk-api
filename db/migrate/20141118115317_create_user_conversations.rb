class CreateUserConversations < ActiveRecord::Migration
  def change
    create_table :user_conversations do |t|
      t.integer :user_id, null: false
      t.integer :conversation_id, null: false
      t.boolean :is_unread, default: true
      t.timestamps
    end
  end
end
