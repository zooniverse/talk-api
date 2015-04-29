class NotificationWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(notification_id)
    notification = ::Notification.find notification_id
    ::Sugar.notify(notification) if notification
  end
end
