# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TagVote, type: :model do
  let(:tag_vote) { build(:tag_vote) }

  context 'validations' do
    it 'errors if no user_id is present' do
      tag_vote.user_id = nil
      expect(tag_vote).to fail_validation user: 'must exist'
    end

    it 'ensures user can only vote for votable_tag once' do
      first_vote = create :tag_vote
      tag_vote.user = first_vote.user
      tag_vote.votable_tag = first_vote.votable_tag
      expect(tag_vote).to fail_validation
    end
  end
end
