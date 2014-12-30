require 'spec_helper'

RSpec.describe DiscussionService, type: :service do
  it_behaves_like 'a service', Discussion do
    let(:current_user){ create :user, roles: { zooniverse: ['moderator'] } }
    let(:params) do
      {
        discussions: {
          title: 'works',
          board_id: create(:board).id,
          comments: [{
            body: 'works'
          }]
        }
      }
    end
  end
end
