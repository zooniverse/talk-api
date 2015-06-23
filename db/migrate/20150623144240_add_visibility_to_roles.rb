class AddVisibilityToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :is_shown, :boolean, null: false, default: true
    add_index :roles, [:user_id, :section, :is_shown]
  end
end
