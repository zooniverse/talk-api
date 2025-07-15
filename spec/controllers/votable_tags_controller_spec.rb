# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VotableTagsController, type: :controller do
  let(:resource) { VotableTag }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
                  destroy: { status: 405, response: :error },
                  update: { status: 405, response: :error },
                  create: { status: 401, response: :error }

  describe '#create' do
    let(:user) { create :user }
    let(:votable_tag_params) do
      {
        votable_tags: {
          section: 'project-1',
          taggable_id: 1,
          taggable_type: 'Subject',
          name: 'hello'
        }
      }
    end
    before(:each) { allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller creating' do
      let(:request_params) { votable_tag_params }
    end

    it 'creates a tag_vote for the created votable_tag' do
      post :create, params:  votable_tag_params.merge(format: :json)
      id = response.json['votable_tags'].first['id']
      tag_votes = TagVote.where(votable_tag_id: id)
      expect(tag_votes.count).to eql 1
      tag_vote = tag_votes[0]
      expect(tag_vote.user_id).to eql(user.id)
    end
  end
end
