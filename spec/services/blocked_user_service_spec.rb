require 'spec_helper'

RSpec.describe BlockedUserService, type: :service do
  it_behaves_like 'a service', BlockedUser do
    let(:other_user){ create :user }
    let(:create_params) do
      {
        blocked_users: {
          blocked_user_id: other_user.id
        }
      }
    end
    
    it_behaves_like 'a service creating', BlockedUser
  end
end
