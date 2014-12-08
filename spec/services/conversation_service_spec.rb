require 'spec_helper'

RSpec.describe ConversationService, type: :service do
  let(:user){ create(:user) }
  let(:recipients){ create_list(:user, 2) }
  let(:params){ }
  let(:service){ ConversationService.new params }
  
  context 'creating a new conversation' do
    let!(:conversation){ service.create_conversation }
    let(:params) do
      {
        body: 'A message',
        title: 'A title',
        user_id: user.id,
        recipient_ids: recipients.collect(&:id)
      }
    end
    
    it 'should create a conversation' do
      expect(conversation).to be_a Conversation
    end
    
    it 'should assign the title' do
      expect(conversation.title).to eql 'A title'
    end
    
    context 'with user conversations' do
      let(:user_conversation){ conversation.user_conversations.where(user_id: user.id).first }
      let(:recipient_conversations){ conversation.user_conversations.where.not(user_id: user.id).all }
      
      it 'should create the user conversation' do
        expect(user_conversation).to be_a UserConversation
      end
      
      it 'should mark the user conversation as read' do
        expect(user_conversation.is_unread).to be false
      end
      
      it 'should create the recipient conversations' do
        recipient_conversations.each do |recipient_conversation|
          expect(recipient_conversation).to be_a UserConversation
        end
      end
      
      it 'should mark the recipient conversations as unread' do
        recipient_conversations.each do |recipient_conversation|
          expect(recipient_conversation.is_unread).to be true
        end
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
          recipient_ids: recipients.collect(&:id)
        }).create_conversation
        expect(conversation).to be_new_record
        expect(conversation).to_not be_valid
       end
       
       it 'should fail user conversation validations' do
         conversation = ConversationService.new({
           body: 'A message',
           title: 'A title',
           recipient_ids: recipients.collect(&:id)
         }).create_conversation
         expect(conversation).to be_new_record
         expect(conversation).to_not be_valid
       end
       
       it 'should fail message validations' do
         conversation = ConversationService.new({
           body: nil,
           title: 'A title',
           recipient_ids: recipients.collect(&:id)
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
        user_id: user.id,
        recipient_ids: recipients.collect(&:id),
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
