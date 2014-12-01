require 'spec_helper'

RSpec.describe Message, type: :model do
  context 'validating' do
    it 'should require a body' do
      without_body = build :message, body: nil
      expect(without_body).to fail_validation body: "can't be blank"
    end
    
    it 'should require a sender' do
      without_sender = build :message, sender: nil, body: 'blah'
      expect(without_sender).to fail_validation sender: "can't be blank"
    end
    
    it 'should require a sender' do
      without_recipient = build :message, recipient: nil, body: 'blah'
      expect(without_recipient).to fail_validation recipient: "can't be blank"
    end
    
    it 'should require a conversation' do
      without_conversation = build :message, conversation: nil
      expect(without_conversation).to fail_validation conversation: "can't be blank"
    end
  end
  
  context 'creating' do
    include_context 'existing conversation'
    
    it 'should set the recipient conversation as unread' do
      expect {
        create :message, conversation: conversation, sender: sender, recipient: recipient
      }.to change {
        recipient_conversation.reload.is_unread
      }.from(false).to true
    end
    
    it 'should not set the sender conversation as unread' do
      expect {
        create :message, conversation: conversation, sender: sender, recipient: recipient
      }.to_not change {
        sender_conversation.reload.is_unread
      }
    end
  end
end
