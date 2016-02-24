class AddIndexes < ActiveRecord::Migration
  def change
    add_index :boards, [:section, :created_at]
    add_index :boards, [:parent_id, :created_at]

    add_index :discussions, [:board_id, :updated_at]
    add_index :discussions, [:board_id, :sticky, :updated_at]
    add_index :discussions, [:board_id, :sticky, :sticky_position]

    add_index :comments, [:created_at]
    add_index :comments, [:discussion_id]
    add_index :comments, [:focus_id, :focus_type]
    add_index :comments, [:user_id]

    add_index :mentions, [:mentionable_id]
    add_index :mentions, [:comment_id]

    add_index :tags, [:taggable_id, :taggable_type]
    add_index :tags, [:section, :taggable_type]
    add_index :tags, [:section, :taggable_type, :name]

    add_index :focuses, [:section, :type]
    add_index :focuses, [:section, :type, :user_id, :created_at]

    add_index :conversations, [:updated_at]

    add_index :user_conversations, [:conversation_id, :user_id]
    add_index :user_conversations, [:conversation_id, :user_id, :is_unread], name: 'unread_user_conversations'

    add_index :messages, [:conversation_id, :created_at]

    add_index :moderations, [:target_id, :target_type]
    add_index :moderations, [:section, :state, :updated_at]

    add_index :users, [:login], unique: true
  end
end
