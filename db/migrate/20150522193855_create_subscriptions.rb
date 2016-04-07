class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :category, null: false
      t.integer :user_id, null: false
      t.integer :source_id, null: false
      t.string :source_type, null: false
      t.timestamps
    end

    add_index :subscriptions, [:source_id, :source_type]
    add_index :subscriptions, [:user_id, :category]
  end
end
