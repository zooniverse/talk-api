require 'spec_helper'

RSpec.describe BoardsController, type: :controller do
  let(:resource){ Board }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    before(:each){ subject.current_user = user }
    it_behaves_like 'a controller rendering', :destroy
  end
end
