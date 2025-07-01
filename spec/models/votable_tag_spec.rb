# frozen_string_literal: true

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

  describe '#soft_destroy' do
    it 'should set is_deleted to true' do
      votable_tag = create :votable_tag, is_deleted: false
      votable_tag.soft_destroy
      expect(votable_tag.is_deleted?).to be true
    end
  end

  describe 'vote_count counter' do
    let(:created_votable_tag) { create(:votable_tag, is_deleted: false, vote_count: 0) }

    it 'should increment if an associated tag_vote is added' do
      expect { create :tag_vote, votable_tag: created_votable_tag }.to change {
                                                                         created_votable_tag.vote_count
                                                                       }.from(0).to(1)
    end

    it 'should decrement if an associated tag_vote is deleted' do
      vote = create :tag_vote, votable_tag: created_votable_tag
      expect { vote.destroy }.to change {
                                   created_votable_tag.vote_count
                                 }.from(1).to(0)
    end
  end
end
