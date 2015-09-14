class AddGroupMentioningToComments < ActiveRecord::Migration
  def change
    add_column :comments, :group_mentioning, :json, null: false, default: { }
  end
end
