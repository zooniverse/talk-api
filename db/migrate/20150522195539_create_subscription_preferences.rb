class CreateSubscriptionPreferences < ActiveRecord::Migration
  def change
    create_table :subscription_preferences do |t|
      t.integer :category, null: false
      t.integer :user_id, null: false
      t.integer :email_digest, null: false, default: 0
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end
    
    add_index :subscription_preferences, [:user_id, :category]
  end
end
