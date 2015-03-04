class RemoveFocuses < ActiveRecord::Migration
  def up
    drop_table :focuses
  end
  
  def down
    create_table :focuses do |t|
      t.string  :type
      t.string  :section,        null: false
      t.string  :name,           null: false
      t.string  :description
      t.integer :comments_count, default: 0
      t.json    :data,           default: { }
      t.integer :user_id
      t.string  :user_login
      t.timestamps
    end
  end
end