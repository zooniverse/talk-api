class AllowNullFocusType < ActiveRecord::Migration
  def up
    change_column :focuses, :type, :string, null: true
  end
  
  def down
    change_column :focuses, :type, :string, null: false
  end
end