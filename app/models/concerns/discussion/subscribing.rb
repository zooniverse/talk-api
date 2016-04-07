class Discussion
  module Subscribing
    extend ActiveSupport::Concern

    included do
      after_commit :notify_subscribers_later, on: :create
    end

    def notify_subscribers_later
      DiscussionSubscriptionWorker.perform_async id
    end

    def notify_subscribers
      subscriptions_to_notify.each do |subscription|
        Notification.create({
          source: self,
          user_id: subscription.user.id,
          message: "#{ user.display_name } started the discussion, #{ title }, on #{ board.title }",
          url: FrontEnd.link_to(self),
          section: section,
          subscription: subscription
        }) if subscription.try(:enabled?)
      end
    end

    def subscriptions_to_notify
      board.subscriptions.started_discussions.enabled.where 'user_id <> ?', user.id
    end
  end
end
