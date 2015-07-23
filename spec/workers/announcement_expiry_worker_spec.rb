require 'spec_helper'

RSpec.describe AnnouncementExpiryWorker, type: :worker do
  it_behaves_like 'an expiry worker', model: Announcement
end
