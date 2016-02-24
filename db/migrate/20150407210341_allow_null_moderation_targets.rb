class AllowNullModerationTargets < ActiveRecord::Migration
  def up
    change_column :moderations, :target_id, :integer, null: true
    change_column :moderations, :target_type, :string, null: true
  end

  def down
    change_column :moderations, :target_id, :integer, null: false
    change_column :moderations, :target_type, :string, null: false
  end
end
