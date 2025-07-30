# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TagVoteService, type: :service do
  it_behaves_like 'a service', TagVote do
    let(:current_user) { create :user }
    let(:votable_tag) { create :votable_tag }
    let(:create_params) do
      {
        tag_votes: {
          votable_tag_id: votable_tag.id
        }
      }
    end

    it_behaves_like 'a service creating', TagVote do
      it 'should set the user_id' do
        expect(service.build.user_id).to eql current_user.id
      end
    end
  end
end
