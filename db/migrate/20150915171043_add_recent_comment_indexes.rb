class AddRecentCommentIndexes < ActiveRecord::Migration
  def change
    add_index :comments, [:board_id, :created_at]
    add_index :comments, [:section, :created_at]
    add_index :comments, [:section, :board_id, :created_at]
  end
end
