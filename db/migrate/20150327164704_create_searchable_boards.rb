class CreateSearchableBoards < ActiveRecord::Migration
  def change
    create_table :searchable_boards, id: false do |t|
      t.primary_key :searchable_id
      t.string :searchable_type, null: false
      t.tsvector :content, null: false, default: ''
      t.string :section, null: false
    end

    add_index :searchable_boards, :content, using: :gin
    add_index :searchable_boards, :section
  end
end
