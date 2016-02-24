class AddBoardPositions < ActiveRecord::Migration
  def change
    add_column :boards, :position, :integer, default: 0

    remove_index :boards, column: [:parent_id, :last_comment_created_at]
    add_index :boards, [:parent_id, :position, :last_comment_created_at], name: 'sub_board_order'

    remove_index :boards, column: [:section, :last_comment_created_at]
    add_index :boards, [:section, :position, :last_comment_created_at], name: 'board_order'
  end
end
