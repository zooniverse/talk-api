require 'spec_helper'

RSpec.describe ConversationsController, type: :controller do
  let(:resource){ Conversation }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index, :show do
      let!(:record){ create :conversation_with_messages, user: user }
    end
    
    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error }
  end
end
