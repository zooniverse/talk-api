require 'spec_helper'

RSpec.describe NotificationExpiryWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe 'schedule' do
    subject{ described_class.schedule.to_s }
    it{ is_expected.to eql 'Daily' }
  end
  
  describe '#perform' do
    it 'should remove expired notifications' do
      expect(Notification).to receive_message_chain :expired, :destroy_all
      subject.perform
    end
  end
end
