class User < ActiveRecord::Base
  include Moderatable
  
  has_many :roles
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  has_many :notifications
  has_many :subscriptions
  has_many :subscription_preferences
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  moderatable_with :watch, by: [:moderator, :admin]
  
  def self.from_panoptes(api_response)
    return unless api_response.success?
    hash = api_response.body['users'].first
    find_by_id hash['id']
  end
  
  def mentioned_by(comment)
    subscription = subscribe_to comment.discussion, :mentions
    
    Notification.create({
      user_id: id,
      message: "You were mentioned by #{ comment.user.display_name }",
      url: Rails.application.routes.url_helpers.comment_url(comment.id),
      section: comment.section,
      subscription: subscription
    }) if subscription.try(:enabled?)
  end
  
  def preference_for(category)
    SubscriptionPreference.find_or_default_for self, category
  end
  
  def subscribe_to(source, category)
    category = Subscription.categories[category]
    Subscription.where(user: self, category: category, source: source).first_or_create
  end
  
  def unsubscribe_from(source, category = nil)
    query = { user: self, source: source }
    query[:category] = Subscription.categories[category] if category
    Subscription.where(query).destroy_all
  end
end
