class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.string :section
      t.json :last_comment
      t.integer :users_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :discussions_count, default: 0
      t.json :permissions, default: { read: :all, write: :all }
      t.timestamps
    end
  end
end
