class AddProjectIds < ActiveRecord::Migration
  def change
    add_column :announcements, :project_id, :integer, null: true
    add_column :boards, :project_id, :integer, null: true
    add_column :comments, :project_id, :integer, null: true
    add_column :discussions, :project_id, :integer, null: true
    add_column :notifications, :project_id, :integer, null: true
    add_column :tags, :project_id, :integer, null: true
  end
end
