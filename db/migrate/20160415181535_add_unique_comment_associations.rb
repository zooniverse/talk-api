class AddUniqueCommentAssociations < ActiveRecord::Migration
  def change
    remove_index :group_mentions, column: [:comment_id, :name]
    add_index :group_mentions, [:comment_id, :name], unique: true
    add_index :mentions, [:mentionable_id, :mentionable_type, :comment_id], unique: true, name: 'index_mentions_on_unique_per_comment'
    add_index :tags, [:comment_id, :name], unique: true
  end
end
