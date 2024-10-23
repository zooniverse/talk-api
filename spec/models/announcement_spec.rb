require 'spec_helper'

RSpec.describe Announcement, type: :model do
  it_behaves_like 'a sectioned model'

  describe '#assign_default_expiration' do
    subject{ create :announcement }
    its(:expires_at){ is_expected.to be_within(1.second).of 1.month.from_now }
  end

  context 'creating' do
    let(:announcement){ build :announcement }
    it 'should publish' do
      expect(AnnouncementWorker).to receive :perform_async
      announcement.save!
    end
  end

  it_behaves_like 'an expirable model' do
    let!(:fresh){ create_list :announcement, 2 }
    let!(:stale){ create_list :announcement, 2, expires_at: 1.year.ago.utc }
  end
end
