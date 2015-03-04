class RenameLogin < ActiveRecord::Migration
  def change
    rename_column :comments, :user_login, :user_display_name
    rename_column :discussions, :user_login, :user_display_name
  end
end
