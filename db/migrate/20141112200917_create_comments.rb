class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :category
      t.text :body, null: false
      t.json :tags, default: { }
      t.integer :focus_id
      t.string :focus_type
      t.string :section
      t.integer :discussion_id
      t.string :discussion_title
      t.integer :board_id
      t.string :board_title
      t.integer :user_id, null: false
      t.string :user_name, null: false
      t.string :user_display_name
      t.boolean :is_deleted, default: false
      t.json :versions, default: []
      t.json :upvotes, default: { }
      t.timestamps
    end
  end
end
