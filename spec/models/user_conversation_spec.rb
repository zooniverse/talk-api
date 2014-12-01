require 'spec_helper'

RSpec.describe UserConversation, type: :model do
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
