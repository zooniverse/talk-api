class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.integer :uses, default: 0
      t.string :section
      t.timestamps
    end
  end
end
