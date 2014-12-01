class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  
  validates :body, presence: true
  validates :sender, presence: true
  validates :recipient, presence: true
  validates :conversation, presence: true
  
  after_create :set_conversation_unread!
  
  protected
  
  def set_conversation_unread!
    recipient_conversation = conversation.user_conversations.where(user_id: recipient.id).first
    recipient_conversation.is_unread = true
    recipient_conversation.save if recipient_conversation.changed?
  end
end
