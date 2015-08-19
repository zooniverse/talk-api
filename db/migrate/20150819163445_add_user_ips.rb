class AddUserIps < ActiveRecord::Migration
  def change
    add_column :comments, :user_ip, :string
    add_column :messages, :user_ip, :string
  end
end