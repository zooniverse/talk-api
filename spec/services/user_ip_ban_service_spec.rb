require 'spec_helper'

RSpec.describe UserIpBanService, type: :service do
  it_behaves_like 'a service', UserIpBan do
    let(:current_user){ create :admin, section: 'zooniverse' }
    let(:parent_board){ create :user_ip_ban }
    let(:create_params) do
      {
        user_ip_bans: {
          ip: '0.0.0.1/24'
        }
      }
    end
    
    it_behaves_like 'a service creating', UserIpBan
  end
end
