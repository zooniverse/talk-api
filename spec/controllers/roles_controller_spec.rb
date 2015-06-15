require 'spec_helper'

RSpec.describe RolesController, type: :controller do
  let(:resource){ Role }
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
    
    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      create: { status: 401, response: :error },
      update: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :admin, section: 'zooniverse' }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index, :show, :destroy
    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          roles: {
            user_id: create(:user).id,
            section: 'project-1',
            name: 'moderator'
          }
        }
      end
    end
    
    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id,
          roles: {
            name: 'scientist'
          }
        }
      end
    end
  end
end
