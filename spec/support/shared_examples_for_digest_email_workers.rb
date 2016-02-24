require 'spec_helper'

RSpec.shared_examples_for 'a digest email worker' do |scope:|
  let(:worker){ described_class.new }

  describe '.frequency' do
    subject{ worker.class.frequency }
    it{ is_expected.to eql scope }
  end

  describe '#perform' do
    let(:enabled){ create_list :subscription_preference, 2, email_digest: scope }
    let(:disabled){ create_list :subscription_preference, 2, enabled: false, email_digest: scope }

    it 'should scope to the frequency' do
      expect(SubscriptionPreference).to receive(scope).and_return SubscriptionPreference.none
      worker.perform
    end

    it 'filter and notify users by enabled preferences' do
      enabled_user_ids = enabled.map &:user_id
      enabled_user_ids.each do |user_id|
        expect(NotificationEmailWorker).to receive(:perform_async).once.with user_id, scope
      end
      worker.perform
    end
  end
end
