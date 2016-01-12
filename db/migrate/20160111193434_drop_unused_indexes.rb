class DropUnusedIndexes < ActiveRecord::Migration
  def change
    remove_index :conversations, columns: [:updated_at], name: 'index_conversations_on_updated_at'
    
    remove_index :roles, columns: [:user_id], name: 'index_roles_on_user_id'
    
    remove_index :discussions, columns: [:board_id, :sticky_position, :last_comment_created_at], name: 'sticky_board_id_coment_created_at'
    remove_index :discussions, columns: [:sticky, :sticky_position, :last_comment_created_at], name: 'sticky_comment_created_at'
    remove_index :discussions, columns: [:board_id, :sticky, :sticky_position, :last_comment_created_at], name: 'sorted_sticky_board_id_comment_created_at'
    
    remove_index :searchable_boards, columns: [:sections, :searchable_type], name: 'index_searchable_boards_on_sections_and_searchable_type'
    add_index :searchable_boards, :sections, using: :gin
    add_index :searchable_boards, :searchable_type
    
    remove_index :searchable_comments, columns: [:sections, :searchable_type], name: 'index_searchable_comments_on_sections_and_searchable_type'
    add_index :searchable_comments, :sections, using: :gin
    add_index :searchable_comments, :searchable_type
    
    remove_index :searchable_discussions, columns: [:sections, :searchable_type], name: 'index_searchable_discussions_on_sections_and_searchable_type'
    add_index :searchable_discussions, :sections, using: :gin
    add_index :searchable_discussions, :searchable_type
  end
end
