class AddBoardIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :board_id, :integer
    add_index :comments, :board_id
  end
end
