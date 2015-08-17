class UserConversation < ActiveRecord::Base
  include Subscribable
  
  belongs_to :conversation
  belongs_to :user, required: true
  
  before_create :update_conversation_participants
  after_destroy :remove_conversation
  
  protected
  
  def remove_conversation
    conversation.reload.destroy rescue nil
  end
  
  def update_conversation_participants
    conversation.participant_ids << user_id
    conversation.participant_ids.uniq!
    conversation.save if conversation.persisted? && conversation.changed?
  end
end
