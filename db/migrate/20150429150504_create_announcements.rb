class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.text :message, null: false
      t.string :section, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :announcements, [:section, :created_at]
    add_index :announcements, :created_at
    add_index :announcements, :expires_at
  end
end
