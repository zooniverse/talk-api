class CreateFocuses < ActiveRecord::Migration
  def change
    create_table :focuses, id: false do |t|
      t.integer :id, null: false
      t.string :type, null: false
      t.string :section
      t.string :name, null: false
      t.string :description
      t.integer :comments_count, default: 0
      t.json :data, default: { }
      t.json :tags, default: { }
      t.timestamps
    end
  end
end
