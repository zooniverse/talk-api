class RefactorTagging < ActiveRecord::Migration
  def change
    remove_column :focuses, :tags, :jsonb
    remove_column :tags, :uses, :integer
    remove_column :comments, :tags, :jsonb
    add_column :comments, :tagging, :json, default: { }
    add_column :tags, :user_id, :integer, null: false
    add_column :tags, :comment_id, :integer, null: false
    add_column :tags, :taggable_id, :integer
    add_column :tags, :taggable_type, :string
  end
end