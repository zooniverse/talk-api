class AddProjectIdToDataRequest < ActiveRecord::Migration
  def change
    add_column :data_requests, :project_id, :integer
  end
end
