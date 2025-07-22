require 'spec_helper'

RSpec.describe TagVoteSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all

  describe 'filtering votable_tag attributes' do
    let(:user) { create :user }
    let(:votable_tag) { create :votable_tag, section: 'project-1', taggable_type: 'Subject', taggable_id: 1 }
    let(:other_votable_tag) { create :votable_tag, section: 'project-2', taggable_type: 'Subject', taggable_id: 2  }
    let!(:tag_vote) { create :tag_vote, votable_tag_id: votable_tag.id, user_id: user.id }
    let!(:other_tag_vote) { create :tag_vote, votable_tag_id: other_votable_tag.id, user_id: user.id }
    let(:serialized_results) { described_class.page(params, TagVote.all, {})[:tag_votes] }

    context 'when filtering by votable_tag section' do
      let(:params) { { section: votable_tag.section } }

      it 'returns the vote with matching tag section' do
        expect(serialized_results.size).to eq(1)
        matching_vote = serialized_results.first
        expect(matching_vote[:id].to_i).to eq(tag_vote.id)
        expect(matching_vote[:votable_tag][:id].to_i).to eq(votable_tag.id)
      end
    end

    context 'when filtering by votable_tag taggable_id' do
      let(:params) { { taggable_id: votable_tag.taggable_id } }

      it 'returns the vote with matching tag taggable_id' do
        expect(serialized_results.size).to eq(1)
        matching_vote = serialized_results.first
        expect(matching_vote[:id].to_i).to eq(tag_vote.id)
        expect(matching_vote[:votable_tag][:id].to_i).to eq(votable_tag.id)
      end
    end
  end
end
