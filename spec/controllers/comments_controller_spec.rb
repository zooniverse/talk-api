require 'spec_helper'

RSpec.describe CommentsController, type: :controller do
  let(:resource){ Comment }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ record.user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller rendering', :destroy
  end
end
