require 'spec_helper'

RSpec.describe User, type: :model do
  it_behaves_like 'moderatable'
  let(:user){ create :user }
  
  describe '#preference_for' do
    it 'should find the subscription preference' do
      expect(SubscriptionPreference).to receive(:find_or_default_for).with user, :mentions
      user.preference_for :mentions
    end
  end
  
  describe '#subscribe_to' do
    let(:discussion){ create :discussion }
    subject{ user.subscribe_to discussion, :mentions }
    
    it{ is_expected.to be_a Subscription }
    it{ is_expected.to be_mentions }
    its(:user){ is_expected.to eql user }
    its(:source){ is_expected.to eql discussion }
  end
  
  describe '#unsubscribe_from' do
    let(:discussion){ create :discussion }
    
    let!(:other_subscription){ create :subscription, source: discussion }
    
    let!(:mention_subscription) do
      user.subscriptions.create source: discussion, category: :mentions
    end
    
    let!(:participating_subscription) do
      user.subscriptions.create source: discussion, category: :participating_discussions
    end
    
    it 'should remove all user subscriptions for a source' do
      user.unsubscribe_from discussion
      expect{ mention_subscription.reload }.to raise_error
      expect{ participating_subscription.reload }.to raise_error
    end
    
    it 'should only remove user subscriptions' do
      user.unsubscribe_from discussion
      expect{ other_subscription.reload }.to_not raise_error
    end
    
    it 'should be limitable to a category' do
      user.unsubscribe_from discussion, :mentions
      expect{ mention_subscription.reload }.to raise_error
      expect{ participating_subscription.reload }.to_not raise_error
    end
  end
  
  describe '#mentioned_by' do
    let(:comment){ create :comment }
    
    it 'should create a notification' do
      expect(Notification).to receive :create
      user.mentioned_by comment
    end
    
    it 'should create a subscription' do
      expect(user).to receive(:subscribe_to).with comment.discussion, :mentions
      user.mentioned_by comment
    end
    
    context 'notification' do
      subject{ user.mentioned_by comment }
      its(:user_id){ is_expected.to eql user.id }
      its(:message){ is_expected.to eql "You were mentioned by #{ comment.user_display_name }" }
      its(:url){ is_expected.to eql "http://localhost:3000/comments/#{ comment.id }" }
      its(:section){ is_expected.to eql comment.section }
    end
    
    context 'when preference is disabled' do
      before(:each){ user.preference_for(:mentions).update_attribute :enabled, false }
      
      it 'should not create a notification' do
        expect(Notification).to_not receive :create
        user.mentioned_by comment
      end
      
      it 'should not create a subscription' do
        expect {
          user.mentioned_by comment
        }.to_not change{
          Subscription.count
        }
      end
    end
  end
end
