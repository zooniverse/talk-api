class CreateTagVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :tag_votes do |t|
      t.integer :user_id, null: false
      t.references :votable_tag, foreign_key: true, null: false

      t.timestamps
    end
  end
end
