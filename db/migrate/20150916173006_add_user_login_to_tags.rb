class AddUserLoginToTags < ActiveRecord::Migration
  def change
    add_column :tags, :user_login, :string
  end
end
