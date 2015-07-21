class CreateDataRequests < ActiveRecord::Migration
  def change
    create_table :data_requests do |t|
      t.integer :user_id, null: false
      t.string :section, null: false
      t.string :kind, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :data_requests, [:section, :kind], unique: true
    add_index :data_requests, :expires_at
  end
end