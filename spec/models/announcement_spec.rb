require 'spec_helper'

RSpec.describe Announcement, type: :model do
  describe '#assign_default_expiration' do
    subject{ create :announcement }
    its(:expires_at){ is_expected.to be_within(1.second).of 1.month.from_now }
  end
  
  context 'creating' do
    it 'should publish' do
      expect(AnnouncementWorker).to receive :perform_async
      create :announcement
    end
  end
end
