class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
      t.integer :id, null: false
      t.string :name, null: false
      t.string :display_name
      t.json :roles, default: { }
      t.json :preferences, default: { }
      t.json :stats, default: { }
      t.timestamps
    end
  end
end
