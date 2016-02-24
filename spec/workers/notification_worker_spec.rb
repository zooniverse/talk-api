require 'spec_helper'

RSpec.describe NotificationWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:notification){ create :notification }

    it 'should notify via sugar' do
      expect(Sugar).to receive(:notify).with notification
      subject.perform notification.id
    end

    context 'when immediate' do
      before :each do
        notification.subscription.preference.update email_digest: :immediate
      end

      it 'should email the user' do
        expect(Sugar).to receive(:notify).with notification
        expect(NotificationEmailWorker).to receive(:perform_async).with notification.user_id, :immediate
        subject.perform notification.id
      end
    end

    context 'when not immediate' do
      before :each do
        notification.subscription.preference.update email_digest: :daily
      end

      it 'should email the user' do
        expect(Sugar).to receive(:notify).with notification
        expect(NotificationEmailWorker).to_not receive :perform_async
        subject.perform notification.id
      end
    end
  end
end
