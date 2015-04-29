class NotificationExpiryWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  sidekiq_options retry: false, backtrace: true
  recurrence{ daily }
  
  def perform
    ::Notification.expired.destroy_all
  end
end
