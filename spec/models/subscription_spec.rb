require 'spec_helper'

RSpec.describe Subscription, type: :model do
  context 'validating' do
    it 'should require a user' do
      without_user = build :subscription, user: nil
      expect(without_user).to_not be_valid
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a category' do
      without_category = build :subscription, category: nil
      expect(without_category).to_not be_valid
      expect(without_category).to fail_validation category: 'is not included in the list'
    end
    
    it 'should require a source' do
      without_source = build :subscription, source: nil
      expect(without_source).to_not be_valid
      expect(without_source).to fail_validation source: "can't be blank"
    end
  end
  
  describe '#preference' do
    let(:user){ create :user }
    let(:subscription){ build :subscription, user: user }
    
    it 'should find the category preference for the user' do
      expect(SubscriptionPreference).to receive(:find_or_default_for)
        .with user, 'participating_discussions'
      subscription.preference
    end
  end
  
  describe '#ensure_enabled' do
    let(:user){ create :user }
    let(:subscription){ build :subscription, user: user }
    
    context 'when enabled' do
      let!(:preference){ create :subscription_preference, user: user, enabled: true }
      
      it 'should create' do
        subscription.save
        expect{ subscription.reload }.to_not raise_error
      end
    end
    
    context 'when disabled' do
      let!(:preference){ create :subscription_preference, user: user, enabled: false }
      
      it 'should not create' do
        subscription.save
        expect{ subscription.reload }.to raise_error
      end
    end
  end
  
  describe '#clear_notifications' do
    let!(:notifications){ create_list :notification, 2, subscription: subscription }
    let!(:other_notification){ create :notification }
    
    context 'when disabling' do
      let!(:subscription){ create :subscription }
      it 'should clear notifications' do
        expect{
          subscription.update_attributes enabled: false
        }.to change{
          Notification.count
        }.from(3).to 1
      end
    end
    
    context 'when not disabling' do
      let!(:subscription){ create :subscription, enabled: false }
      it 'should not clear notifications' do
        expect{
          subscription.update_attributes enabled: true
        }.to_not change{
          Notification.count
        }
      end
    end
  end
end
