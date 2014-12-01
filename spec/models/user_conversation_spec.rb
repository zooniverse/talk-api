require 'spec_helper'

RSpec.describe UserConversation, type: :model do
  context 'validating' do
    it 'should require a user' do
      without_user = build :user_conversation, user_id: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
  end
  
  context 'destroying' do
    include_context 'existing conversation'
    
    it 'should not destroy the conversation if a user conversation still exists' do
      expect {
        conversation.user_conversations.first.destroy
        conversation.reload
      }.to_not raise_exception
    end
    
    it 'destroy the conversation if no user conversations exist' do
      expect {
        conversation.user_conversations.map &:destroy
        conversation.reload
      }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
