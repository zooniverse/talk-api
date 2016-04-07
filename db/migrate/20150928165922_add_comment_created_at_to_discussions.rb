class AddCommentCreatedAtToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :last_comment_created_at, :datetime

    remove_index :discussions, column: [:board_id, :sticky, :sticky_position, :updated_at], name: 'sticky_board_id_updated_at'
    remove_index :discussions, column: [:board_id, :sticky_position, :updated_at], name: 'board_id_and_sticky_and_updated_at'
    remove_index :discussions, column: [:board_id, :updated_at]
    remove_index :discussions, column: [:sticky, :sticky_position, :updated_at]

    add_index :discussions, [:board_id, :sticky, :sticky_position, :last_comment_created_at], name: 'sorted_sticky_board_id_comment_created_at'
    add_index :discussions, [:board_id, :sticky_position, :last_comment_created_at], name: 'sticky_board_id_coment_created_at'
    add_index :discussions, [:board_id, :last_comment_created_at]
    add_index :discussions, [:sticky, :sticky_position, :last_comment_created_at], name: 'sticky_comment_created_at'
  end
end
