require 'spec_helper'

RSpec.describe DiscussionService, type: :service do
  it_behaves_like 'a service', Discussion do
    let(:current_user){ create :user, roles: { zooniverse: ['moderator'] } }
    let(:board){ create :board }
    let(:create_params) do
      {
        discussions: {
          title: 'works',
          board_id: board.id,
          comments: [{
            body: 'works'
          }]
        }
      }
    end
    
    it_behaves_like 'a service creating', Discussion
    
    context 'creating the discussion' do
      before(:each){ service.create }
      subject{ service.resource }
      its(:title){ is_expected.to eql 'works' }
      its(:board){ is_expected.to eql board }
      its(:user){ is_expected.to eql current_user }
      
      context 'with a comment' do
        subject{ service.resource.comments.first }
        its(:body){ is_expected.to eql 'works' }
        its(:discussion){ is_expected.to eql service.resource }
        its(:user){ is_expected.to eql current_user }
      end
    end
    
    it_behaves_like 'a service updating', Discussion do
      let(:update_params) do
        {
          id: record.id,
          discussions: {
            title: 'changed'
          }
        }
      end
    end
  end
end
