require 'spec_helper'

RSpec.describe Conversation, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a title' do
      without_title = build :conversation, title: nil
      expect(without_title).to fail_validation title: "can't be blank"
    end
    
    it 'should limit title length' do
      short_title = build :conversation, title: 'a'
      expect(short_title).to fail_validation title: 'too short'
      long_title = build :conversation, title: '!' * 200
      expect(long_title).to fail_validation title: 'too long'
    end
  end
  
  describe '.for_user' do
    let(:conversation){ create :conversation_with_messages }
    let(:user){ conversation.users.first }
    let(:other){ create :user }
    
    it 'should find conversations for a user' do
      expect(Conversation.for_user(user).first).to eql conversation
    end
    
    it 'should exclude conversations for other users' do
      expect(Conversation.for_user(other)).to be_empty
    end
  end
  
  describe '.unread' do
    let!(:conversation){ create :conversation_with_messages }
    
    it 'should find unread conversations' do
      expect(Conversation.unread.first).to eql conversation
    end
    
    it 'should exclude read conversations' do
      conversation.user_conversations.update_all is_unread: false
      expect(Conversation.unread).to be_empty
    end
  end
end
