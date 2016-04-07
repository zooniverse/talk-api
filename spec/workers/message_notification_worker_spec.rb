require 'spec_helper'

RSpec.describe MessageNotificationWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:message){ create :message }

    it 'should notify the subscribers' do
      allow(Message).to receive(:find).with(message.id).and_return message
      expect(message).to receive :notify_subscribers
      subject.perform message.id
    end
  end
end
