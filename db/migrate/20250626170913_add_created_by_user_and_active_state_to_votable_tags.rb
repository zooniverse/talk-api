class AddCreatedByUserAndActiveStateToVotableTags < ActiveRecord::Migration[7.0]
  def change
    add_column :votable_tags, :created_by_user_id, :integer
    add_column :votable_tags, :is_deleted, :boolean, default: false
  end
end
