require 'spec_helper'

RSpec.describe ModerationService, type: :service do
  it_behaves_like 'a service', Moderation do
    let(:target){ create :comment }
    let(:params) do
      {
        moderations: {
          section: 'test',
          target_id: target.id,
          target_type: target.class.name,
          reports: [{
            message: 'works'
          }]
        }
      }
    end
    
    context 'creating a moderation' do
      before(:each){ service.create }
      subject{ service.resource }
      
      its(:target){ is_expected.to eql target }
      its(:section){ is_expected.to eql 'test' }
      its(:reports){ is_expected.to include 'message' => 'works', 'user_id' => current_user.id }
    end
  end
end
