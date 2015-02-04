class AddSubBoards < ActiveRecord::Migration
  def change
    add_column :boards, :board_id, :integer
  end
end
