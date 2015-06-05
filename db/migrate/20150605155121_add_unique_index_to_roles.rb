class AddUniqueIndexToRoles < ActiveRecord::Migration
  def change
    add_index :roles, [:user_id, :section, :name], unique: true
  end
end
