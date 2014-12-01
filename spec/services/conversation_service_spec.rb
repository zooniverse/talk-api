require 'spec_helper'

RSpec.describe ConversationService, type: :service do
  let(:sender){ create(:user) }
  let(:recipient){ create(:user) }
  let(:params){ }
  let(:service){ ConversationService.new params }
  
  context 'creating a new conversation' do
    let!(:conversation){ service.create_conversation }
    let(:params) do
      {
        body: 'A message',
        title: 'A title',
        sender_id: sender.id,
        recipient_id: recipient.id
      }
    end
    
    it 'should create a conversation' do
      expect(conversation).to be_a Conversation
    end
    
    it 'should assign the title' do
      expect(conversation.title).to eql 'A title'
    end
    
    context 'with user conversations' do
      let(:sender_conversation){ conversation.user_conversations.where(user_id: sender.id).first }
      let(:recipient_conversation){ conversation.user_conversations.where(user_id: recipient.id).first }
      
      it 'should create the sender conversation' do
        expect(sender_conversation).to be_a UserConversation
      end
      
      it 'should mark the sender conversation as read' do
        expect(sender_conversation.is_unread).to be false
      end
      
      it 'should create the recipient conversation' do
        expect(recipient_conversation).to be_a UserConversation
      end
      
      it 'should mark the recipient conversation as unread' do
        expect(recipient_conversation.is_unread).to be true
      end
    end
    
    context 'with a message' do
      it_behaves_like 'a created message' do
        let(:message){ conversation.messages.first }
      end
    end
    
    context 'with errors' do
      it 'should fail conversation validations' do
        conversation = ConversationService.new({
          body: 'A message',
          title: nil,
          sender_id: sender.id,
          recipient_id: recipient.id
        }).create_conversation
        expect(conversation).to be_new_record
        expect(conversation).to_not be_valid
       end
       
       it 'should fail user conversation validations' do
         conversation = ConversationService.new({
           body: 'A message',
           title: 'A title',
           sender_id: sender.id
         }).create_conversation
         expect(conversation).to be_new_record
         expect(conversation).to_not be_valid
       end
       
       it 'should fail message validations' do
         conversation = ConversationService.new({
           body: nil,
           title: 'A title',
           sender_id: sender.id,
           recipient_id: recipient.id
         }).create_conversation
         expect(conversation).to be_new_record
         expect(conversation).to_not be_valid
       end
    end
  end
  
  context 'creating a message in an existing conversation' do
    include_context 'existing conversation'
    let(:params) do
      {
        body: 'A message',
        sender_id: sender.id,
        recipient_id: recipient.id,
        conversation_id: conversation.id
      }
    end
    
    it_behaves_like 'a created message' do
      let(:message){ service.create_message }
    end
    
    context 'with errors' do
      it 'should fail validations' do
        message = ConversationService.new({ }).create_message
        expect(message).to be_new_record
        expect(message).to_not be_valid
      end
    end
  end
end
