class CreateSuggestedTags < ActiveRecord::Migration
  def change
    create_table :suggested_tags do |t|
      t.string :name, required: true
      t.string :section, required: true
      t.timestamps
    end

    add_index :suggested_tags, [:name, :section], unique: true
  end
end
