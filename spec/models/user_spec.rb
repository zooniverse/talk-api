require 'spec_helper'

RSpec.describe User, type: :model do
  it_behaves_like 'moderatable'
  let(:user){ create :user }
  
  describe '.from_panoptes' do
    let!(:access_token){ create :oauth_access_token, resource_owner: user }
    
    it 'should find a user' do
      expect(User.from_panoptes(access_token.token)).to eql user
    end
  end
  
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
    
    context 'when the preference is disabled' do
      before(:each){ create :subscription_preference, category: :mentions, user: user, enabled: false }
      it{ is_expected.to be_nil }
    end
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
    
    it 'should disable all user subscriptions for a source' do
      user.unsubscribe_from discussion
      expect(mention_subscription.reload).to_not be_enabled
      expect(participating_subscription.reload).to_not be_enabled
    end
    
    it 'should only remove user subscriptions' do
      user.unsubscribe_from discussion
      expect(other_subscription.reload).to be_enabled
    end
    
    it 'should be limitable to a category' do
      user.unsubscribe_from discussion, :mentions
      expect(mention_subscription.reload).to_not be_enabled
      expect(participating_subscription.reload).to be_enabled
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
      its(:message){ is_expected.to eql "You were mentioned by #{ comment.user.display_name } in #{ comment.discussion.title }" }
      its(:url){ is_expected.to eql FrontEnd.link_to(comment) }
      its(:section){ is_expected.to eql comment.section }
      its(:source){ is_expected.to eql comment }
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
          Subscription.mentions.count
        }
      end
    end
  end
end
