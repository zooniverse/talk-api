class AddReplyToComments < ActiveRecord::Migration
  def change
    add_column :comments, :reply_id, :integer
  end
end
