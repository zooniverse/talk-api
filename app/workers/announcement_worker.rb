require 'sugar'

class AnnouncementWorker
  include Sidekiq::Worker

  sidekiq_options retry: true, backtrace: true

  def perform(announcement_id)
    announcement = ::Announcement.find announcement_id
    ::Sugar.announce(announcement) if announcement
  end
end
