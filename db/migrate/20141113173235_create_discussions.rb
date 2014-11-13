class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :title, null: false
      t.integer :first_comment_id
      t.string :section
      t.integer :board_id
      t.string :board_title
      t.integer :user_id, null: false
      t.string :user_name, null: false
      t.string :user_display_name
      t.boolean :sticky, default: false
      t.boolean :locked, default: false
      t.json :last_comment
      t.integer :users_count, default: 0
      t.integer :comments_count, default: 0
      t.timestamps
    end
  end
end
