require 'rspec'

RSpec.describe Mention, type: :model do
  let(:focus){ create :subject }
  
  describe '#notify_later' do
    it 'should queue the notification' do
      mention = create :mention, mentionable: focus
      expect(MentionWorker).to receive(:perform_async).with mention.id
      mention.run_callbacks :commit
    end
  end
  
  describe '#notify_mentioned' do
    it 'should notify of the mention' do
      mention = create :mention, mentionable: focus
      expect(focus).to receive(:mentioned_by).with mention.comment
      mention.notify_mentioned
    end
  end
end
