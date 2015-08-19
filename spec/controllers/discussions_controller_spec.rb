require 'spec_helper'

RSpec.describe DiscussionsController, type: :controller do
  let(:resource){ Discussion }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :moderator, section: 'zooniverse' }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :destroy
    it_behaves_like 'a controller creating' do
      let(:request_params) do
        {
          discussions: {
            title: 'works',
            board_id: create(:board).id.to_s,
            comments: [{
              body: 'works'
            }]
          }
        }
      end
      
      it 'should set the user ip' do
        post :create, request_params.merge(format: :json)
        discussion_id = response.json['discussions'].first['id']
        comment = Comment.where(discussion_id: discussion_id).first
        expect(comment.user_ip).to eql request.remote_ip
      end
    end
    
    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id.to_s,
          discussions: {
            title: 'changed',
            sticky: true
          }
        }
      end
    end
  end
  
  context 'with the owner' do
    it_behaves_like 'a controller updating' do
      let(:current_user){ record.user }
      let(:schema_method){ :owner_update }
      let(:request_params) do
        {
          id: record.id.to_s,
          discussions: {
            title: 'changed'
          }
        }
      end
    end
  end
end
