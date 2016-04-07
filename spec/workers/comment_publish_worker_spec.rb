require 'spec_helper'

RSpec.describe CommentPublishWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:comment){ create :comment }

    before(:each) do
      allow(Comment).to receive(:find).with(comment.id).and_return comment
    end

    it 'should publish' do
      expect(comment).to receive(:publish_to_event_stream)
      subject.perform comment.id
    end
  end
end
