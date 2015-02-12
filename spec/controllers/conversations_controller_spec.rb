require 'spec_helper'

RSpec.describe ConversationsController, type: :controller do
  let(:resource){ Conversation }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error },
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index, :show do
      let!(:record){ create :conversation_with_messages, user: user }
    end
    
    it_behaves_like 'a controller creating' do
      let(:recipients){ create_list :user, 2 }
      let(:recipient_ids){ recipients.collect &:id }
      
      let(:request_params) do
        {
          conversations: {
            title: 'works',
            body: 'a message',
            recipient_ids: recipient_ids
          }
        }
      end
    end
    
    it_behaves_like 'a controller restricting',
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  describe '#index' do
    context 'filtering unread' do
      let(:record){ create :conversation_with_messages }
      let(:recipient){ record.user_conversations.where(is_unread: true).first.user }
      let(:sender){ record.user_conversations.where(is_unread: false ).first.user }
      let(:json){ get(:index, unread: true); response.json['conversations'] }
      
      before(:each) do
        allow(subject).to receive(:current_user).and_return current_user
      end
      
      context 'finding conversations' do
        let(:current_user){ recipient }
        
        it 'should respond with the conversation' do
          expect(json.length).to eql 1
          expect(json.first['id']).to eql record.id
        end
      end
      
      context 'excluding conversations' do
        let(:current_user){ sender }
        
        it 'should not respond with the conversation' do
          expect(json).to be_empty
        end
      end
    end
  end
  
  describe '#show' do
    context 'marking as read' do
      let(:record){ create :conversation_with_messages }
      let(:recipient){ record.user_conversations.where(is_unread: true).first.user }
      
      before(:each) do
        allow(subject).to receive(:current_user).and_return recipient
      end
      
      it 'should mark the conversation as read' do
        expect(Conversation).to receive(:mark_as_read_by).with [record.id], recipient.id
        get :show, id: record.id
      end
    end
  end
end
