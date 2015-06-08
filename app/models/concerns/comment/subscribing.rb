class Comment
  module Subscribing
    extend ActiveSupport::Concern
    
    included do
      after_create :notify_subscribers, :subscribe_user
    end
    
    def notify_subscribers
      discussion.subscriptions.participating_discussions.each do |subscription|
        next if subscription.user == user
        Notification.create({
          user_id: subscription.user.id,
          message: "#{ user.display_name } commented on #{ discussion.title }: #{ body }",
          url: Rails.application.routes.url_helpers.comment_url(id),
          section: section,
          subscription: subscription
        }) if subscription.try(:enabled?)
      end
    end
    
    def subscribe_user
      user.subscribe_to discussion, :participating_discussions
    end
  end
end
