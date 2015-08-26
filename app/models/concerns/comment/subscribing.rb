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
      subscriptions_to_notify.each do |subscription|
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
    
    def subscriptions_to_notify
      list = discussion.subscriptions.participating_discussions.enabled.where 'user_id <> ?', user.id
      list += discussion.subscriptions.followed_discussions.enabled.where 'user_id <> ?', user.id
      list.uniq{ |subscription| subscription.user_id }
    end
    
    def subscribe_user
      user.subscribe_to discussion, :participating_discussions
    end
  end
end
