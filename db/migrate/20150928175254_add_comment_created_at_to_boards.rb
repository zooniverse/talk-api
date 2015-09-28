class AddCommentCreatedAtToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :last_comment_created_at, :datetime
    
    remove_index :boards, column: [:parent_id, :created_at]
    remove_index :boards, column: [:section, :created_at]
    
    add_index :boards, [:parent_id, :last_comment_created_at]
    add_index :boards, [:section, :last_comment_created_at]
  end
end
