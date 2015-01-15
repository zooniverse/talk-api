require 'rspec'

RSpec.describe Mention, type: :model do
  let(:focus){ create :focus }
  let(:comment){ build :comment, body: "^S#{ focus.id }" }
  let(:mention){ comment.mentions.first }
  
  describe '#notify_mentioned' do
    it 'should notify of the mention' do
      comment.parse_mentions
      allow(mention).to receive(:mentionable).and_return focus
      expect(focus).to receive(:mentioned_by).with comment
      comment.save!
    end
  end
end
