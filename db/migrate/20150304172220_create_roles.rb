class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :user_id, null: false
      t.string :scope, null: false
      t.string :name, null: false
    end
  end
end
