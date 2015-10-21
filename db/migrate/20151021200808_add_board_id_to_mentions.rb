class AddBoardIdToMentions < ActiveRecord::Migration
  def change
    add_column :mentions, :board_id, :integer
  end
end
