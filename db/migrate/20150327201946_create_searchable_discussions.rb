class CreateSearchableDiscussions < ActiveRecord::Migration
  def change
    create_table :searchable_discussions, id: false do |t|
      t.primary_key :searchable_id
      t.string :searchable_type, null: false
      t.tsvector :content, null: false, default: ''
      t.string :section, null: false
    end

    add_index :searchable_discussions, :content, using: :gin
    add_index :searchable_discussions, :section
  end
end
