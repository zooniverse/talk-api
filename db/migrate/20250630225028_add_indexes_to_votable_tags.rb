class AddIndexesToVotableTags < ActiveRecord::Migration[7.0]
  def change
    add_index :votable_tags, [:taggable_id, :taggable_type]
    add_index :votable_tags, [:section, :taggable_type]
    add_index :votable_tags, [:section, :taggable_type, :name]
    add_index :votable_tags, [:taggable_id, :taggable_type, :name], unique: true, name: 'index_votable_tags_by_name_and_taggable', where: 'is_deleted = false'
    add_index :votable_tags, [:created_by_user_id]
  end
end
