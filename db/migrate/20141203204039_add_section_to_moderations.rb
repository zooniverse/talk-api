class AddSectionToModerations < ActiveRecord::Migration
  def up
    add_column :moderations, :section, :string
  end

  def down
    remove_column :moderations, :section
  end
end
