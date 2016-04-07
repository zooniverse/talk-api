class NotificationEmailWorker
  include Sidekiq::Worker

  sidekiq_options congestion: {
    interval: 1.hour,
    max_in_interval: 10,
    min_delay: 5.minutes,
    reject_with: :reschedule,
    track_rejected: false,
    key: ->(user_id, digest) {
      "user_#{ user_id }_notification_emails"
    }
  }, retry: true, backtrace: true

  def perform(user_id, digest)
    user = ::User.find user_id
    digest_number = SubscriptionPreference.email_digests[digest]

    # Ensure there are categories delivered at this frequency
    categories = user.subscription_preferences.enabled.where(email_digest: digest_number).pluck :category
    return unless categories.present?

    # Ensure there are undelivered notifications for this user and digest level
    return unless user.notifications.undelivered.joins(:subscription).where(subscriptions: { category: categories }).exists?

    ::NotificationMailer.notify(user, digest).deliver_now!
  end
end
