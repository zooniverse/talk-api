class CreateVotableTags < ActiveRecord::Migration[7.0]
  def change
    create_table :votable_tags do |t|
      t.string :name, null: false
      t.integer :project_id
      t.string :section
      t.references :taggable, polymorphic: true
      t.integer :created_by_user_id
      t.boolean :is_deleted, default: false
      t.integer :vote_count, null: false, default: 0

      t.timestamps
    end
  end
end
