class RenameDisplayName < ActiveRecord::Migration
  def change
    rename_column :comments, :user_display_name, :user_login
    rename_column :discussions, :user_display_name, :user_login
  end
end
