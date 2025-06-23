class AddIndexesToVotableTags < ActiveRecord::Migration[7.0]
  def change
    add_index :votable_tags, [:taggable_id, :taggable_type]
    add_index :votable_tags, [:section, :taggable_type]
    add_index :votable_tags, [:section, :taggable_type, :name]
    add_index :votable_tags, [:taggable_id, :taggable_type, :name], unique: true
  end
end
