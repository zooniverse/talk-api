require 'spec_helper'

RSpec.describe ConversationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:messages, :users]
  
  it_behaves_like 'a moderatable serializer' do
    let(:record){ create :conversation_with_messages }
    # actually, only participants
    let(:not_logged_in_actions){ [:report] }
    let(:logged_in_actions){ [:report] }
    
    let(:moderator_actions){ [:report, :destroy, :ignore] }
    let(:admin_actions){ [:report, :destroy, :ignore] }
  end
  
  describe '.default_sort' do
    let!(:unread_conversation){ create :conversation_with_messages, updated_at: 1.minute.ago.utc }
    let(:recipient){ unread_conversation.user_conversations.where(is_unread: true).first.user }
    let(:sender){ unread_conversation.user_conversations.where(is_unread: false ).first.user }
    let!(:read_conversation){ create :read_conversation, user: sender, recipients: [recipient] }
    let!(:old_read_conversation){ create :read_conversation, user: sender, recipients: [recipient] }
    let(:policy_scope){ ConversationPolicy::Scope.new recipient, Conversation }
    let(:json){ ConversationSerializer.page({ sort: ConversationSerializer.default_sort }, policy_scope.resolve, current_user: recipient) }
    let(:conversation_ids){ json[:conversations].collect{ |h| h[:id] } }
    
    it 'should order by unread first and updated at' do
      unread_conversation.update_attribute 'updated_at', 1.minute.ago.utc
      read_conversation.update_attribute 'updated_at', 2.minutes.ago.utc
      old_read_conversation.update_attribute 'updated_at', 10.minute.ago.utc
      expect(conversation_ids).to eql [
        unread_conversation.id.to_s,
        read_conversation.id.to_s,
        old_read_conversation.id.to_s
      ]
    end
  end
  
  describe '.is_unread' do
    let!(:unread_conversation){ create :conversation_with_messages }
    let(:recipient){ unread_conversation.user_conversations.where(is_unread: true).first.user }
    let(:sender){ unread_conversation.user_conversations.where(is_unread: false ).first.user }
    let!(:read_conversation){ create :read_conversation, user: sender, recipients: [recipient] }
    let(:policy_scope){ ConversationPolicy::Scope.new recipient, Conversation }
    let(:json){ ConversationSerializer.page({ sort: ConversationSerializer.default_sort }, policy_scope.resolve, current_user: recipient) }
    
    it 'should indicate unread conversations' do
      conversation = json[:conversations].find{ |h| h[:id] == unread_conversation.id.to_s }
      expect(conversation[:is_unread]).to be true
    end
    
    it 'should indicate read conversations' do
      conversation = json[:conversations].find{ |h| h[:id] == read_conversation.id.to_s }
      expect(conversation[:is_unread]).to be false
    end
  end
end
