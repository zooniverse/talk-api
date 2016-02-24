require 'spec_helper'

RSpec.describe ModerationNotificationWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:moderation){ create :moderation }

    it 'should notify the subscribers' do
      allow(Moderation).to receive(:find).with(moderation.id).and_return moderation
      expect(moderation).to receive :notify_subscribers
      subject.perform moderation.id
    end
  end
end
