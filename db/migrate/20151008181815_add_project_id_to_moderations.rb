class AddProjectIdToModerations < ActiveRecord::Migration
  def change
    add_column :moderations, :project_id, :integer
  end
end
