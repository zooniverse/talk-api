require 'spec_helper'

RSpec.describe GroupMentionWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:group_mention){ create :group_mention }

    it 'should notify the mentionable' do
      allow(GroupMention).to receive(:find).with(group_mention.id).and_return group_mention
      expect(group_mention).to receive :notify_mentioned
      subject.perform group_mention.id
    end
  end
end
