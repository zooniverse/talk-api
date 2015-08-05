class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index :comments, [:discussion_id, :created_at]
    add_index :discussions, [:sticky, :sticky_position, :updated_at]
    add_index :discussions, [:board_id, :sticky, :sticky_position, :updated_at], name: 'index_discussions_on_sticky_board_id_updated_at'
    add_index :tags, :comment_id
  end
end
