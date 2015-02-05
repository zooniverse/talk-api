require 'spec_helper'

RSpec.describe Focus, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a section' do
      without_section = build :focus, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
  
  describe '#tags' do
    let(:focus){ create :focus }
    
    it 'should find popular tags' do
      query = double
      tags = double
      expect(Tag).to receive(:where).with(taggable_id: focus.id).and_return query
      expect(query).to receive(:popular).with(limit: 10).and_return tags
      expect(tags).to receive :keys
      focus.tags
    end
  end
end
