class AddSectionToMentions < ActiveRecord::Migration
  def change
    add_column :mentions, :section, :string
    add_column :mentions, :project_id, :integer
  end
end
