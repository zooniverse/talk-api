class AddEnabledToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :enabled, :boolean, null: false, default: true
  end
end
