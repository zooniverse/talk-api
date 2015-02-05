class AddStickyPositionToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :sticky_position, :integer
  end
end
