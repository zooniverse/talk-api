class RemoveDenormalizedAttributes < ActiveRecord::Migration
  def up
    remove_column :comments, :discussion_title
    remove_column :comments, :board_id
    remove_column :comments, :board_title
    remove_column :comments, :user_display_name
    remove_column :discussions, :first_comment_id
    remove_column :discussions, :board_title
    remove_column :discussions, :user_display_name
    remove_column :discussions, :last_comment
    remove_column :boards, :last_comment
  end
  
  def down
    add_column :comments, :discussion_title, :string
    add_column :comments, :board_id, :integer
    add_column :comments, :board_title, :string
    add_column :comments, :user_display_name, :string
    add_column :discussions, :first_comment_id, :integer
    add_column :discussions, :board_title, :string
    add_column :discussions, :user_display_name, :string
    add_column :discussions, :last_comment, :json
    add_column :boards, :last_comment, :json
  end
end
