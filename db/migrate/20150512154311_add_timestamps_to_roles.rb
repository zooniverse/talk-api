class AddTimestampsToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :created_at, :datetime
    add_column :roles, :updated_at, :datetime
  end
end
