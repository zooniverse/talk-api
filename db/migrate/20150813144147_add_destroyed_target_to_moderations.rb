class AddDestroyedTargetToModerations < ActiveRecord::Migration
  def change
    add_column :moderations, :destroyed_target, :json
  end
end
