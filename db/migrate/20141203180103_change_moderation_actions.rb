class ChangeModerationActions < ActiveRecord::Migration
  def up
    rename_column :moderations, :action, :actions
    change_column_default :moderations, :actions, [ ]
  end
  
  def down
    rename_column :moderations, :actions, :action
    change_column_default :moderations, :action, nil
  end
end
