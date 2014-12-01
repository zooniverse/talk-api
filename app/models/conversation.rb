class Conversation < ActiveRecord::Base
  has_many :user_conversations, dependent: :restrict_with_exception
  has_many :users, through: :user_conversations
  has_many :messages, dependent: :destroy
  
  validates :title, presence: true, length: 3..140
end
