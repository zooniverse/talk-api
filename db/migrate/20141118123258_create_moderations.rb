class CreateModerations < ActiveRecord::Migration
  def change
    create_table :moderations do |t|
      t.integer :target_id, null: false
      t.string :target_type, null: false
      t.integer :state, default: 0
      t.json :reports, default: []
      t.json :action
      t.datetime :actioned_at
      t.timestamps
    end
  end
end
