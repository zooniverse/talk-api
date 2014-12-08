require 'spec_helper'

RSpec.describe Message, type: :model do
  context 'validating' do
    it 'should require a body' do
      without_body = build :message, body: nil
      expect(without_body).to fail_validation body: "can't be blank"
    end
    
    it 'should require a user' do
      without_user = build :message, user: nil, body: 'blah'
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a conversation' do
      without_conversation = build :message, conversation: nil
      expect(without_conversation).to fail_validation conversation: "can't be blank"
    end
  end
  
  context 'creating' do
    include_context 'existing conversation'
    
    it 'should set the recipient conversations as unread' do
      expect {
        create :message, conversation: conversation, user: user
      }.to change {
        recipient_conversations.collect{ |c| c.reload.is_unread }.uniq
      }.from([false]).to [true]
    end
    
    it 'should not set the user conversation as unread' do
      expect {
        create :message, conversation: conversation, user: user
      }.to_not change {
        user_conversation.reload.is_unread
      }
    end
  end
end
