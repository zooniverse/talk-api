class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :mentionable_id, null: false
      t.string :mentionable_type, null: false
      t.integer :comment_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
