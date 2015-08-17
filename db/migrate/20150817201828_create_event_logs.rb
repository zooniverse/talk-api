class CreateEventLogs < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.integer :user_id
      t.json :payload
      t.timestamps
    end
  end
end
