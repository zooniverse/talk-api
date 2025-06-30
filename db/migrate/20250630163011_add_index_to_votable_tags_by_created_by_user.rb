class AddIndexToVotableTagsByCreatedByUser < ActiveRecord::Migration[7.0]
  def change
    add_index :votable_tags, [:created_by_user_id]
  end
end
