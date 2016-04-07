require 'spec_helper'

RSpec.describe CommentSubscriptionWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:comment){ create :comment }

    it 'should notify the subscribers' do
      allow(Comment).to receive(:find).with(comment.id).and_return comment
      expect(comment).to receive :notify_subscribers
      subject.perform comment.id
    end
  end
end
