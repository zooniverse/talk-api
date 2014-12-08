class User < ActiveRecord::Base
  include Moderatable
  
  has_many :collections
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  moderatable_with :watch, by: [:moderator, :admin]
end
