class AnnouncementExpiryWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  sidekiq_options retry: false, backtrace: true
  recurrence{ hourly }
  
  def perform
    ::Announcement.expired.destroy_all
  end
end
