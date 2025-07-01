class AddIndexesToTagVotes < ActiveRecord::Migration[7.0]
  def change
    add_index :tag_votes, :user_id
    add_index :tag_votes, [:user_id, :votable_tag_id], unique: true
  end
end
