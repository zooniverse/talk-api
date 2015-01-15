class AddMentioningToComments < ActiveRecord::Migration
  def change
    add_column :comments, :mentioning, :json, null: false, default: { }
  end
end
