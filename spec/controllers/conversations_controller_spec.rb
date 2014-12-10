require 'spec_helper'

RSpec.describe ConversationsController, type: :controller do
  it_behaves_like 'a controller', Conversation
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller restricting', Conversation,
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller rendering', Conversation, :index, :show do
      let!(:record){ create :conversation_with_messages, user: user }
    end
  end
end
