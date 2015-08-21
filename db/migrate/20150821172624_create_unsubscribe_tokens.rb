class CreateUnsubscribeTokens < ActiveRecord::Migration
  def change
    create_table :unsubscribe_tokens do |t|
      t.integer :user_id, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
    end
    
    add_index :unsubscribe_tokens, :token, unique: true
    add_index :unsubscribe_tokens, :user_id, unique: true
    add_index :unsubscribe_tokens, :expires_at
  end
end
