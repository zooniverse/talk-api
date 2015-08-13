class AddParticipantIdsToConversation < ActiveRecord::Migration
  def change
    add_column :conversations, :participant_ids, :integer, array: true, default: []
  end
end
