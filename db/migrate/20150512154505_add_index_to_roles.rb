class AddIndexToRoles < ActiveRecord::Migration
  def change
    add_index :roles, :user_id
  end
end