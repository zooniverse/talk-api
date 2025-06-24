class AddVoteCountToVotableTags < ActiveRecord::Migration[7.0]
  def change
    add_column :votable_tags, :vote_count, :integer, null: false, default: 0
  end
end
