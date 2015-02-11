class RenameBoardParentKey < ActiveRecord::Migration
  def change
    rename_column :boards, :board_id, :parent_id
  end
end