require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  let(:resource){ User }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    destroy: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    it_behaves_like 'a controller restricting',
      index: { status: 401, response: :error },
      update: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return create(:user) }
    it_behaves_like 'a controller rendering', :index, :show
  end
end
