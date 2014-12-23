require 'spec_helper'

RSpec.describe MessagesController, type: :controller do
  let(:resource){ Message }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    destroy: { status: 401, response: :error }
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller restricting',
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    before(:each){ subject.current_user = record.user }
    it_behaves_like 'a controller rendering', :index, :show
  end
end
