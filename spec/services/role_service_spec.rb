require 'spec_helper'

RSpec.describe RoleService, type: :service do
  it_behaves_like 'a service', Role, sets_user: false do
    let(:current_user){ create :admin, section: 'project-1' }
    let(:create_params) do
      {
        roles: {
          user_id: create(:user).id,
          section: 'project-1',
          name: 'moderator'
        }
      }
    end
    
    it_behaves_like 'a service creating', Role
    it_behaves_like 'a service updating', Role do
      let(:current_user){ create :admin, section: 'project-1' }
      let(:update_params) do
        {
          id: record.id,
          roles: {
            name: 'scientist',
            is_shown: false
          }
        }
      end
    end
  end
end
