class User < ActiveRecord::Base
  include Moderatable
  
  has_many :roles
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  has_many :notifications
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  moderatable_with :watch, by: [:moderator, :admin]
  
  def self.from_panoptes(api_response)
    return unless api_response.success?
    hash = api_response.body['users'].first
    find_by_id hash['id']
  end
  
  def mentioned_by(comment)
    # TO-DO: notification
  end
end
