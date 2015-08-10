class AddSourceToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :source_id, :integer
    add_column :notifications, :source_type, :string
    add_index :notifications, [:source_id, :source_type]
  end
end
