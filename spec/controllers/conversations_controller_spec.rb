require 'spec_helper'

RSpec.describe ConversationsController, type: :controller do
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    it 'should be spec\'d'
  end
  
  context 'with an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller rendering', Conversation, :index, :show do
      let!(:record){ create :conversation_with_messages, user: user }
    end
  end
end
