class AddLabelToEventLogs < ActiveRecord::Migration
  def change
    add_column :event_logs, :label, :string
  end
end
