# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TagVotesController, type: :controller do
  let(:resource) { TagVote }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
                  update: { status: 405, response: :error }

  context 'without authorized user' do
    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
                    destroy: { status: 401, response: :error },
                    create: { status: 401, response: :error }
  end

  context 'with authorized user' do
    let(:user) { create :user }
    let(:votable_tag) { create :votable_tag }
    let(:tag_vote_create_params) do
      {
        tag_votes: {
          votable_tag_id: votable_tag.id
        }
      }
    end

    before(:each) { allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller creating' do
      let(:request_params) do
        {
          tag_votes: {
            votable_tag_id: votable_tag.id
          }
        }
      end
    end

    describe '#destroy' do
      context 'user owns the tag_vote' do
        let(:tag_vote) { create :tag_vote, votable_tag_id: votable_tag.id, user_id: user.id }
        before(:each) { delete :destroy, params: { id: tag_vote.id, format: :json } }

        it 'destroys the tag_vote' do
          tag_votes_count = TagVote.all.count
          expect(tag_votes_count).to eq(0)
        end

        it 'sets the associated votable_tag is_deleted to true if no more votes upon removal' do
          votable_tag.reload
          expect(votable_tag.is_deleted).to eq(true)
        end

        it 'does not soft_destroy votable_tag if there is still a vote on the tag' do
          multiple_voted_votable_tag = create :votable_tag, vote_count: 1
          user_vote = create :tag_vote, votable_tag_id: multiple_voted_votable_tag.id, user_id: user.id
          multiple_voted_votable_tag.reload

          delete :destroy, params: { id: user_vote.id, format: :json }
          multiple_voted_votable_tag.reload
          expect(multiple_voted_votable_tag.is_deleted).to eq(false)
        end
      end

      context 'user does not own the vote' do
        let(:other_user) { create :user }
        let(:other_users_vote) { create :tag_vote, votable_tag_id: votable_tag.id, user_id: other_user.id }

        it_behaves_like 'a controller restricting',
                        destroy: { status: 401, response: :error }

        it 'does not destroy the tag_vote' do
          delete :destroy, params: { id: other_users_vote.id, format: :json }
          tag_votes = TagVote.all
          expect(tag_votes.count).to eq(1)
          expect(tag_votes[0].id).to eq(other_users_vote.id)
        end
      end
    end
  end
end
