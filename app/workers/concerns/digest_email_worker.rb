module DigestEmailWorker
  extend ActiveSupport::Concern

  included do
    include Sidekiq::Worker

    sidekiq_options retry: false, backtrace: true
  end

  def perform
    scope = ::SubscriptionPreference.send self.class.frequency
    user_ids = scope.enabled.select(:user_id).distinct.pluck :user_id
    user_ids.each do |user_id|
      ::NotificationEmailWorker.perform_async user_id, self.class.frequency
    end
  end
end
