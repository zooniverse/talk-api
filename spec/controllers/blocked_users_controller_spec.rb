require 'spec_helper'

RSpec.describe BlockedUsersController, type: :controller do
  let(:resource){ BlockedUser }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  
  it_behaves_like 'a controller restricting',
    index: { status: 401, response: :error },
    show: { status: 401, response: :error },
    create: { status: 401, response: :error },
    destroy: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    let(:user){ create :user }
    let(:other_user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index
    it_behaves_like 'a controller restricting',
      show: { status: 401, response: :error },
      destroy: { status: 401, response: :error },
      update: { status: 401, response: :error }
    
    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          blocked_users: {
            blocked_user_id: other_user.id
          }
        }
      end
    end
  end
  
  context 'with an authorized user' do
    let(:record){ create :blocked_user }
    before(:each){ allow(subject).to receive(:current_user).and_return record.user }
    
    it_behaves_like 'a controller rendering', :index, :show, :destroy
    it_behaves_like 'a controller restricting',
      update: { status: 401, response: :error }
  end
end
