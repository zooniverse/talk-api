class AddStateToDataRequest < ActiveRecord::Migration
  def change
    add_column :data_requests, :state, :integer, default: 0, null: false
  end
end
