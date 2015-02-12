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
  
  describe '.mark_as_read_by' do
    let(:user){ create :user }
    let!(:conversations){ create_list :conversation_with_messages, 2, recipients: [user] }
    let(:user_conversations){ UserConversation.where user_id: user.id }
    
    context 'with a single conversation' do
      let(:to_read){ conversations.first }
      let(:unread){ conversations.last }
      
      it 'should mark the user conversation' do
        user_conversation = to_read.user_conversations.where(user_id: user.id).first
        expect {
          Conversation.mark_as_read_by to_read.id, user
        }.to change {
          user_conversation.reload.is_unread
        }.from(true).to false
      end
      
      it 'should not mark other user conversations' do
        user_conversation = unread.user_conversations.where(user_id: user.id).first
        expect {
          Conversation.mark_as_read_by to_read.id, user
        }.to_not change {
          user_conversation.reload.is_unread
        }
      end
    end
    
    context 'with multiple conversations' do
      it 'should mark the user conversations' do
        user_conversations = conversations.collect do |conversation|
          conversation.user_conversations.where(user_id: user.id).first
        end
        
        expect {
          Conversation.mark_as_read_by conversations.collect(&:id), user
        }.to change {
          user_conversations.collect{ |uc| uc.reload.is_unread }
        }.from([true, true]).to [false, false]
      end
    end
  end
end
