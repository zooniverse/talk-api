class CreateSearchableComments < ActiveRecord::Migration
  def change
    create_table :searchable_comments, id: false do |t|
      t.primary_key :searchable_id
      t.string :searchable_type, null: false
      t.tsvector :content, null: false, default: ''
      t.string :section, null: false
    end
    
    add_index :searchable_comments, :content, using: :gin
    add_index :searchable_comments, :section
  end
end
