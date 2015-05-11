class RenameRoleScope < ActiveRecord::Migration
  def change
    rename_column :roles, :scope, :section
  end
end
