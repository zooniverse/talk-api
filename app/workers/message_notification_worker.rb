class MessageNotificationWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(message_id)
    message = ::Message.find message_id
    message.notify_subscribers
  end
end
