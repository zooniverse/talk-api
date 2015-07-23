class NotificationExpiryWorker
  include ExpiryWorker
  self.model = ::Notification
end
