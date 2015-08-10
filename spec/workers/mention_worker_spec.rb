require 'spec_helper'

RSpec.describe MentionWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe '#perform' do
    let(:focus){ create :subject }
    let(:mention){ create :mention, mentionable: focus }
    
    it 'should notify the mentionable' do
      allow(Mention).to receive(:find).with(mention.id).and_return mention
      expect(mention).to receive :notify_mentioned
      subject.perform mention.id
    end
  end
end
