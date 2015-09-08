require 'spec_helper'

RSpec.describe UserIpBansController, type: :controller do
  let(:resource){ UserIpBan }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      index: { status: 401, response: :error },
      show: { status: 401, response: :error },
      create: { status: 401, response: :error },
      destroy: { status: 401, response: :error },
      update: { status: 405, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :admin, section: 'zooniverse' }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index, :show, :destroy
    it_behaves_like 'a controller restricting',
      update: { status: 405, response: :error }
    
    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          user_ip_bans: {
            ip: '1.2.3.4/24'
          }
        }
      end
    end
  end
end
