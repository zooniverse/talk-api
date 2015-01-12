class ChangeCommentTagsToArray < ActiveRecord::Migration
  def change
    remove_column :comments, :tags
    add_column :comments, :tags, :string, array: true, default: [], null: false
  end
end
