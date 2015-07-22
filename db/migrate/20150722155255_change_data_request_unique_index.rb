class ChangeDataRequestUniqueIndex < ActiveRecord::Migration
  def change
    remove_index :data_requests, [:section, :kind]
    add_index :data_requests, [:section, :kind, :user_id], unique: true
  end
end
