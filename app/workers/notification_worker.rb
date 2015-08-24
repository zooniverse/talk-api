require 'sugar'

class NotificationWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(notification_id)
    notification = ::Notification.where(id: notification_id).eager_load(:subscription).first
    return unless notification
    ::Sugar.notify notification
    NotificationEmailWorker.perform_async(notification.user_id, :immediate) if notification.immediate?
  end
end
