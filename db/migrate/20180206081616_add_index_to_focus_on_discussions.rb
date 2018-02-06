class AddIndexToFocusOnDiscussions < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :discussions, %i(focus_id focus_type), algorithm: :concurrently
  end
end
