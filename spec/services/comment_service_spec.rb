require 'spec_helper'

RSpec.describe CommentService, type: :service do
  it_behaves_like 'a service', Comment do
    let(:create_params) do
      {
        comments: {
          body: 'works',
          discussion_id: create(:discussion).id
        }
      }
    end
    
    context 'creating the comment' do
      before(:each){ service.create }
      subject{ service.resource }
      its(:user){ is_expected.to eql current_user }
    end
    
    it_behaves_like 'a service creating', 'Comment'
    it_behaves_like 'a service updating', Comment do
      let(:record){ create :comment, user: current_user }
      let(:update_params) do
        {
          id: record.id,
          comments: {
            body: 'changed'
          }
        }
      end
    end
  end
end
