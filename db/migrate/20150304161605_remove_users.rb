class RemoveUsers < ActiveRecord::Migration
  def up
    drop_table :users
  end

  def down
    create_table :users do |t|
      t.string   :login,                     null: false
      t.string   :display_name
      t.json     :roles,        default: { }
      t.json     :preferences,  default: { }
      t.json     :stats,        default: { }
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :email,                     null: false
    end
  end
end
