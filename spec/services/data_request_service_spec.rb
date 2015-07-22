require 'spec_helper'

RSpec.describe DataRequestService, type: :service do
  it_behaves_like 'a service', DataRequest do
    let(:current_user){ create :admin, section: 'project-1' }
    let(:create_params) do
      {
        data_requests: {
          section: 'project-1',
          kind: 'tags'
        }
      }
    end
    
    it_behaves_like 'a service creating', DataRequest
  end
end
