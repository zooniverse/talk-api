class AddGroupMentionIndexes < ActiveRecord::Migration
  def change
    add_index :group_mentions, :comment_id
    add_index :group_mentions, [:comment_id, :name]
  end
end
