require 'spec_helper'

RSpec.describe DataRequestsController, type: :controller do
  let(:resource){ DataRequest }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index
    it_behaves_like 'a controller restricting',
      show: { status: 401, response: :error },
      create: { status: 401, response: :error },
      update: { status: 405, response: :error },
      destroy: { status: 405, response: :error }
  end

  context 'with an authorized user' do
    let(:user){ create :admin, section: 'zooniverse' }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      update: { status: 405, response: :error },
      destroy: { status: 405, response: :error }

    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          data_requests: {
            section: 'project-1',
            kind: 'tags'
          }
        }
      end
    end
  end
end
