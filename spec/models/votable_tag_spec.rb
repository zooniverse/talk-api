require 'spec_helper'

RSpec.describe VotableTag, type: :model do
  let(:votable_tag) { build(:votable_tag) }
  it_behaves_like 'a sectioned model'

  context 'validations' do
    it 'errors if no section is present' do
      votable_tag.section = nil
      expect(votable_tag).to fail_validation section: "can't be blank"
    end

    it 'errors if taggable_type is null when taggable_id is present' do
      votable_tag.taggable_id = 12
      expect(votable_tag).to fail_validation taggable_type: "can't be blank"
    end

    it 'errors if taggable_id is null when taggable_type is present' do
      votable_tag.taggable_type = 'Subject'
      expect(votable_tag).to fail_validation taggable_id: "can't be blank"
    end

    it 'accepts if neither taggable_id nor taggable_type present as valid' do
      expect(votable_tag).to be_valid
    end

    it 'accepts if both taggable_id and taggable_type present as valid' do
      votable_tag.taggable_type = 'Subject'
      votable_tag.taggable_id = 1
      expect(votable_tag).to be_valid
    end
  end
end
