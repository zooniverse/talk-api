class CreateVotableTags < ActiveRecord::Migration[7.0]
  def change
    create_table :votable_tags do |t|
      t.string :name, null: false
      t.integer :project_id
      t.string :section
      t.references :taggable, polymorphic: true

      t.timestamps
    end
  end
end
