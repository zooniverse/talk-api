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
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :destroy
    it_behaves_like 'a controller creating' do
      let(:request_params) do
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
end
