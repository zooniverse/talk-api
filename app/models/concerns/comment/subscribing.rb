class Comment
  module Subscribing
    extend ActiveSupport::Concern
    
    included do
      after_create :subscribe_user
      after_commit :notify_subscribers_later, on: :create
    end
    
    def notify_subscribers_later
      CommentSubscriptionWorker.perform_async id
    end
    
    def notify_subscribers
      discussion.subscriptions.participating_discussions.each do |subscription|
        next if subscription.user == user
        Notification.create({
          source: self,
          user_id: subscription.user.id,
          message: "#{ user.display_name } commented on #{ discussion.title }",
          url: FrontEnd.link_to(self),
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
