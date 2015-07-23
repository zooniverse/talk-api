class AnnouncementExpiryWorker
  include ExpiryWorker
  self.model = ::Announcement
end
