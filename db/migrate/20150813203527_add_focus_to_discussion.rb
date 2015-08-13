class AddFocusToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :focus_id, :integer
    add_column :discussions, :focus_type, :string
  end
end
