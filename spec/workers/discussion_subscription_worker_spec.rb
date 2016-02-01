require 'spec_helper'

RSpec.describe DiscussionSubscriptionWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe '#perform' do
    let(:discussion){ create :discussion }
    
    it 'should notify the subscribers' do
      allow(Discussion).to receive(:find).with(discussion.id).and_return discussion
      expect(discussion).to receive :notify_subscribers
      subject.perform discussion.id
    end
  end
end
