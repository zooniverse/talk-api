class Conversation < ActiveRecord::Base
  has_many :messages, dependent: :destroy
  has_many :user_conversations, dependent: :restrict_with_exception
  has_many :users, through: :user_conversations
  
  validates :title, presence: true, length: 3..140
end
