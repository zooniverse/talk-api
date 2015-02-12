class Conversation < ActiveRecord::Base
  include Moderatable
  
  has_many :user_conversations, dependent: :restrict_with_exception
  has_many :users, through: :user_conversations
  has_many :messages, dependent: :destroy
  
  scope :for_user, ->(user){ joins(:user_conversations).where user_conversations: { user_id: user.id } }
  scope :unread, ->{ joins(:user_conversations).where user_conversations: { is_unread: true } }
  
  validates :title, presence: true, length: 3..140
  
  moderatable_with :destroy, by: [:moderator, :admin]
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:owner]
end
