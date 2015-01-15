class User < ActiveRecord::Base
  include ApiResource
  include Moderatable
  
  has_many :collections
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  moderatable_with :watch, by: [:moderator, :admin]
  
  panoptes_attribute :id
  panoptes_attribute :login
  panoptes_attribute :email
  panoptes_attribute :display_name, updateable: true
  
  def mentioned_by(comment)
    # TO-DO: notification
  end
end
