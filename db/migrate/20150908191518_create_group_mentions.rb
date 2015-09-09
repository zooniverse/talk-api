class CreateGroupMentions < ActiveRecord::Migration
  def change
    create_table :group_mentions do |t|
      t.integer :user_id
      t.integer :comment_id
      t.string :section
      t.string :name
      t.timestamps
    end
  end
end
