require 'spec_helper'

RSpec.describe AnnouncementService, type: :service do
  it_behaves_like 'a service', Announcement do
    let(:current_user){ create :admin, section: 'project-1' }
    let(:create_params) do
      {
        announcements: {
          message: 'works',
          section: 'project-1',
          expires_at: 1.hour.from_now.as_json
        }
      }
    end

    it_behaves_like 'a service creating', Announcement
    it_behaves_like 'a service updating', Announcement do
      let(:current_user){ create :admin, section: 'zooniverse' }
      let(:update_params) do
        {
          id: record.id,
          announcements: {
            message: 'works better',
            section: 'zooniverse',
            expires_at: 2.hours.from_now.as_json
          }
        }
      end
    end
  end
end
