require 'rspec'

RSpec.describe Mention, type: :model do
  let(:focus){ create :subject }
  
  describe '#notify_mentioned' do
    it 'should notify of the mention' do
      mention = build :mention, mentionable: focus
      expect(focus).to receive(:mentioned_by).with mention.comment
      mention.save!
    end
  end
end
