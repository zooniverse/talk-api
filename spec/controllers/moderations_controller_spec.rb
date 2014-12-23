require 'spec_helper'

RSpec.describe ModerationsController, type: :controller do
  let(:resource){ Moderation }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return create(:user) }
    it_behaves_like 'a controller restricting',
      index: { status: 401, response: :error },
      show: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    it_behaves_like 'a controller rendering', :index, :show, :destroy
  end
end
