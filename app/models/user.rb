class User < ActiveRecord::Base
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
end
