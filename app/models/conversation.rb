class Conversation < ActiveRecord::Base
  include Moderatable
  
  has_many :user_conversations, dependent: :restrict_with_exception
  has_many :users, through: :user_conversations
  has_many :messages, dependent: :destroy
  
  scope :for_user, ->(user){ joins(:user_conversations).where user_conversations: { user_id: user.id } }
  scope :unread, ->{ joins(:user_conversations).where user_conversations: { is_unread: true } }
  
  default_scope do
    includes(:user_conversations)
      .order 'user_conversations.is_unread desc, conversations.updated_at desc'
  end
  
  validates :title, presence: true, length: 3..140
  
  moderatable_with :destroy, by: [:moderator, :admin]
  moderatable_with :ignore, by: [:moderator, :admin]
  # All users able to view a conversation are able to report it
  # moderatable_with :report, by: [:participant]
  
  def self.mark_as_read_by(conversation_ids, user_id)
    UserConversation.where({
      conversation_id: Array.wrap(conversation_ids),
      user_id: user_id,
      is_unread: true
    }).update_all is_unread: false
  end
end
