require 'spec_helper'

RSpec.describe Message, type: :model do
  it_behaves_like 'a notifiable model'
  
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
  
  describe '#subscribe_user' do
    let(:sender_subscription) do
      Subscription.messages.where source: user_conversation, user: user
    end
    
    let(:recipient_subscriptions) do
      Subscription.messages.where source: recipient_conversations, user: recipients
    end
    
    context 'when preference is enabled' do
      include_context 'existing conversation'
      
      it 'should subscribe messaging users' do
        expect(user_conversation.subscriptions.exists?).to be true
      end
      
      it 'should subscribe messaged users' do
        expect(recipient_subscriptions.exists?).to be true
        expect(recipient_subscriptions.collect(&:user)).to match_array recipients
      end
    end
    
    context 'when preference is disabled' do
      context 'for the sender' do
        before(:each) do
          user.preference_for(:messages).update_attributes enabled: false
        end
        include_context 'existing conversation'
        
        it 'should not subscribe the sender' do
          expect(sender_subscription.exists?).to be false
        end
        
        it 'should subscribe the recipients' do
          expect(recipient_subscriptions.exists?).to be true
        end
      end
      
      context 'for the recipient' do
        before(:each) do
          recipients.each do |recipient|
            recipient.preference_for(:messages).update_attributes enabled: false
          end
        end
        include_context 'existing conversation'
        
        it 'should not subscribe the recipients' do
          expect(recipient_subscriptions.exists?).to be false
        end
        
        it 'should subscribe the sender' do
          expect(sender_subscription.exists?).to be true
        end
      end
    end
  end
  
  describe '#notify_subscribers' do
    before(:each) do
      user.preference_for(:messages).update_attributes enabled: false
    end
    include_context 'existing conversation'
    
    let(:recipient_notifications){ Notification.where subscription: recipient_subscriptions }
    let(:recipient_subscriptions) do
      Subscription.messages.where source: recipient_conversations, user: recipients
    end
    
    it 'should create notifications for subscribed users' do
      conversation.messages.each &:notify_subscribers
      notified_users = recipient_notifications.reload.collect &:user
      expect(notified_users.uniq).to match_array recipients
    end
    
    it 'should not create notifications for unsubscribed users' do
      conversation.messages.each &:notify_subscribers
      expect(Notification.where(user: user).exists?).to be false
    end
    
    it 'should not create a notification for the messaging user' do
      sender = recipients.first
      message = create :message, user: sender, conversation: conversation
      message.notify_subscribers
      expect(Notification.where(user: sender).exists?).to be false
    end
    
    context 'notification' do
      before(:each){ conversation.messages.each &:notify_subscribers }
      subject{ recipient_notifications.first }
      its(:user){ is_expected.to be_in recipients }
      its(:message){ is_expected.to eql "#{ user.display_name } has sent you a message" }
      its(:url){ is_expected.to eql FrontEnd.link_to(conversation.messages.first) }
      its(:source){ is_expected.to be_in conversation.messages }
      its(:section){ is_expected.to eql 'zooniverse' }
    end
  end
end
