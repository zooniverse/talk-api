require 'spec_helper'

RSpec.describe UserService, type: :service do
  it_behaves_like 'a service', User do
    let(:current_user){ create :user }
    
    it_behaves_like 'a service updating', User do
      let(:record){ current_user }
      let(:update_params) do
        {
          id: record.id,
          users: {
            preferences: {
              something: true
            }
          }
        }
      end
    end
  end
end
