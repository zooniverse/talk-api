require 'spec_helper'

RSpec.describe BoardsController, type: :controller do
  let(:resource){ Board }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller creating' do
    let(:current_user){ create :user, roles: { test: ['admin'] } }
    let(:request_params) do
      {
        boards: {
          title: 'works',
          description: 'works',
          section: 'test'
        }
      }
    end
  end
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    it_behaves_like 'a controller rendering', :destroy
  end
end
