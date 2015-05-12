require 'spec_helper'

RSpec.describe RoleService, type: :service do
  it_behaves_like 'a service', Role, sets_user: false do
    let(:current_user){ create :admin, section: 'test' }
    let(:parent_board){ create :role }
    let(:create_params) do
      {
        roles: {
          user_id: create(:user).id,
          section: 'test',
          name: 'moderator'
        }
      }
    end
    
    it_behaves_like 'a service creating', Role
    it_behaves_like 'a service updating', Role do
      let(:current_user){ create :admin, section: 'test' }
      let(:update_params) do
        {
          id: record.id,
          roles: {
            section: 'other',
            name: 'scientist'
          }
        }
      end
    end
  end
end
