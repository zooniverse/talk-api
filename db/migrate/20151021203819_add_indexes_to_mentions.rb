class AddIndexesToMentions < ActiveRecord::Migration
  def change
    remove_index :mentions, column: :mentionable_id
    add_index :mentions, [:mentionable_id, :mentionable_type]
    add_index :mentions, [:mentionable_id, :mentionable_type, :created_at], name: 'mentionable_created_at'
    add_index :mentions, [:mentionable_id, :mentionable_type, :section, :created_at], name: 'mentionable_section_created_at'
    add_index :mentions, :board_id
  end
end
