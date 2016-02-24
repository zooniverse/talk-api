class RemoveJsonb < ActiveRecord::Migration
  def up
    enable_extension :hstore
    change_column_with_cast :boards, :permissions, :json, default: { }
    remove_column :comments, :upvotes
    add_column :comments, :upvotes, :hstore, default: { }
    change_column_with_cast :users, :roles, :json, default: { }
  end

  def down
    # change_column_with_cast :boards, :permissions, :jsonb, default: { }
    # remove_column :comments, :upvotes
    # add_column :comments, :upvotes, :jsonb, default: { }
    # change_column_with_cast :users, :roles, :jsonb, default: { }
    change_column_with_cast :boards, :permissions, :json, default: { }
    remove_column :comments, :upvotes
    add_column :comments, :upvotes, :json, default: { }
    change_column_with_cast :users, :roles, :json, default: { }
    disable_extension :hstore
  end
end
