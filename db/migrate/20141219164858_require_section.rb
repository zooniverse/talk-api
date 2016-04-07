class RequireSection < ActiveRecord::Migration
  def up
    change_column :boards,      :section, :string, null: false
    change_column :comments,    :section, :string, null: false
    change_column :discussions, :section, :string, null: false
    change_column :focuses,     :section, :string, null: false
    change_column :moderations, :section, :string, null: false
    change_column :tags,        :section, :string, null: false
  end

  def down
    change_column :boards,      :section, :string
    change_column :comments,    :section, :string
    change_column :discussions, :section, :string
    change_column :focuses,     :section, :string
    change_column :moderations, :section, :string
    change_column :tags,        :section, :string
  end
end
