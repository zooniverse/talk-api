class Message < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :conversation, required: true
  has_many :user_conversations, through: :conversation
  has_many :users, through: :user_conversations
  
  has_many :recipient_conversations,
    ->(message){
      where.not(user_id: message.user_id)
    },
    class_name: 'UserConversation',
    through: :conversation,
    source: :user_conversations
  
  has_many :recipients,
    class_name: 'User',
    through: :recipient_conversations,
    source: :user
  
  validates :body, presence: true
  
  after_create :set_conversations_unread!
  
  protected
  
  def set_conversations_unread!
    recipient_conversations.update_all is_unread: true
  end
end
