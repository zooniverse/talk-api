class ChangeUserName < ActiveRecord::Migration
  def change
    rename_column :users, :name, :login
    rename_column :comments, :user_name, :user_login
    rename_column :discussions, :user_name, :user_login
    rename_column :focuses, :user_name, :user_login
  end
end