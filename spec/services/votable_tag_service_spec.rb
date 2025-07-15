# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VotableTagService, type: :service do
  it_behaves_like 'a service', VotableTag do
    let(:current_user) { create :user }
    let(:create_params) do
      {
        votable_tags: {
          section: 'project-1',
          name: 'tags'
        }
      }
    end

    it_behaves_like 'a service creating', VotableTag do
      it 'should set the created_by_user_id' do
        expect(service.build.created_by_user_id).to eql current_user.id
      end
    end
  end
end
