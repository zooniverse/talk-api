class EditUniqueIndexOnVotableTags < ActiveRecord::Migration[7.0]
  def change
    remove_index :votable_tags, [:taggable_id, :taggable_type, :name], unique: true
    add_index :votable_tags, [:taggable_id, :taggable_type, :name, :is_deleted], unique: true, name: 'index_votable_tags_by_name_and_taggable'
  end
end
