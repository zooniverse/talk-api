require 'spec_helper'

RSpec.describe Tag, type: :model do
  context 'validating' do
    it 'should require a section' do
      without_section = build :tag, section: nil, comment: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
  
  describe '#propagate_values' do
    let(:comment){ create :comment_for_focus }
    subject(:tag){ Tag.new name: 'test', comment: comment }
    before(:each){ tag.valid? }
    
    its(:section){ is_expected.to eql comment.section }
    its(:user){ is_expected.to eql comment.user }
    its(:taggable){ is_expected.to eql comment.focus }
  end
end
