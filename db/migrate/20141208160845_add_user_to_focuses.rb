class AddUserToFocuses < ActiveRecord::Migration
  def change
    add_column :focuses, :user_id, :integer
    add_column :focuses, :user_name, :string
  end
end
