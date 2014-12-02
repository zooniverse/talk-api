class Message < ActiveRecord::Base
  belongs_to :conversation, required: true
  belongs_to :sender, class_name: 'User', required: true
  belongs_to :recipient, class_name: 'User', required: true
  
  validates :body, presence: true
  
  after_create :set_conversation_unread!
  
  protected
  
  def set_conversation_unread!
    recipient_conversation = conversation.user_conversations.where(user_id: recipient.id).first
    recipient_conversation.is_unread = true
    recipient_conversation.save if recipient_conversation.changed?
  end
end
