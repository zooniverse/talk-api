require 'spec_helper'

RSpec.describe AnnouncementExpiryWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe 'schedule' do
    subject{ described_class.schedule.to_s }
    it{ is_expected.to eql 'Hourly' }
  end
  
  describe '#perform' do
    it 'should remove expired announcements' do
      expect(Announcement).to receive_message_chain :expired, :destroy_all
      subject.perform
    end
  end
end
