class ModerationNotificationWorker
  include Sidekiq::Worker

  sidekiq_options retry: true, backtrace: true

  def perform(moderation_id)
    moderation = ::Moderation.find moderation_id
    moderation.notify_subscribers
  end
end
