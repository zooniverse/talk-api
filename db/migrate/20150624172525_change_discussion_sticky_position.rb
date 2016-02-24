class ChangeDiscussionStickyPosition < ActiveRecord::Migration
  def up
    change_column :discussions, :sticky_position, :float
    remove_index :discussions, [:board_id, :sticky, :sticky_position]
    add_index :discussions, [:board_id, :sticky, :sticky_position], where: 'sticky = true'
  end

  def down
    remove_index :discussions, [:board_id, :sticky, :sticky_position]
    add_index :discussions, [:board_id, :sticky, :sticky_position]
    change_column :discussions, :sticky_position, :integer
  end
end
