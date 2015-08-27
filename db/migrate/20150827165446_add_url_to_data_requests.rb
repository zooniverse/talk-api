class AddUrlToDataRequests < ActiveRecord::Migration
  def change
    add_column :data_requests, :url, :string
  end
end
