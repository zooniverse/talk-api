class AddSearchableTypeIndex < ActiveRecord::Migration
  def up
    remove_index :searchable_boards, :section
    remove_index :searchable_discussions, :section
    remove_index :searchable_comments, :section

    add_index :searchable_boards, [:section, :searchable_type]
    add_index :searchable_discussions, [:section, :searchable_type]
    add_index :searchable_comments, [:section, :searchable_type]
  end

  def down
    remove_index :searchable_boards, [:section, :searchable_type]
    remove_index :searchable_discussions, [:section, :searchable_type]
    remove_index :searchable_comments, [:section, :searchable_type]

    add_index :searchable_boards, :section
    add_index :searchable_discussions, :section
    add_index :searchable_comments, :section
  end
end
