require 'spec_helper'

RSpec.describe SubscriptionPreference, type: :model do
  context 'validating' do
    it 'should require a user' do
      without_user = build :subscription_preference, user: nil
      expect(without_user).to_not be_valid
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a category' do
      without_category = build :subscription_preference, category: nil
      expect(without_category).to_not be_valid
      expect(without_category).to fail_validation category: 'is not included in the list'
    end
    
    it 'should require an enabled preference' do
      without_enabled = build :subscription_preference, enabled: nil
      expect(without_enabled).to_not be_valid
      expect(without_enabled).to fail_validation enabled: 'is not included in the list'
    end
  end
  
  describe '.defaults' do
    subject{ described_class.defaults }
    its([:participating_discussions]){ is_expected.to eql :daily }
    its([:mentions]){ is_expected.to eql :immediate }
    its([:messages]){ is_expected.to eql :immediate }
  end
  
  describe '.find_or_default_for' do
    let(:user){ create :user }
    let(:preference){ described_class.find_or_default_for user, :mentions }
    subject{ preference }
    
    its(:user){ is_expected.to eql user }
    its(:category){ is_expected.to eql 'mentions' }
    its(:email_digest){ is_expected.to eql described_class.defaults[:mentions].to_s }
    
    it 'should create from defaults' do
      expect(described_class).to receive :create
      preference
    end
    
    it 'should find existing preferences' do
      first, second = 2.times.collect do
        described_class.find_or_default_for user, :mentions
      end
      expect(first).to eql second
    end
  end
  
  describe '.for_user' do
    let(:user){ create :user }
    subject{ described_class.for_user user }
    
    its([:participating_discussions]){ is_expected.to be_a described_class }
    its([:participating_discussions]){ is_expected.to be_participating_discussions }
    its([:mentions]){ is_expected.to be_a described_class }
    its([:mentions]){ is_expected.to be_mentions  }
    its([:messages]){ is_expected.to be_a described_class }
    its([:messages]){ is_expected.to be_messages }
    its([:system]){ is_expected.to be_a described_class }
    its([:system]){ is_expected.to be_system }
    
    it 'should .find_or_default_for each category' do
      expect(described_class).to receive(:find_or_default_for)
        .exactly(described_class.categories.length).times
      subject
    end
  end
  
  describe '.enabled' do
    let!(:enabled){ create_list :subscription_preference, 2 }
    let!(:disabled){ create_list :subscription_preference, 2, enabled: false }
    
    it 'should filter' do
      expect(SubscriptionPreference.enabled).to match_array enabled
    end
  end
  
  describe 'updating' do
    let(:preference){ create :subscription_preference }
    
    context 'when disabling' do
      it 'should unsubscribe the user' do
        expect(preference).to receive :unsubscribe_user
        preference.update enabled: false
      end
    end
    
    context 'when not disabling' do
      it 'should not unsubscribe the user' do
        expect(preference).to_not receive :unsubscribe_user
        preference.update email_digest: :never, enabled: true
      end
    end
  end
  
  describe '#unsubscribe_user' do
    let(:preference){ create :subscription_preference, category: :participating_discussions }
    let!(:subscriptions){ create_list :subscription, 2, category: :participating_discussions, user: preference.user }
    let!(:others) do
      create_list(:subscription, 2, category: preference.category) +
      create_list(:subscription, 2, category: :messages, user: preference.user )
    end
    
    it 'should disable the subscriptions in the category' do
      preference.update enabled: false
      expect(subscriptions.map(&:reload)).to_not be_any &:enabled
      expect(others.map(&:reload)).to be_all &:enabled
    end
  end
end
