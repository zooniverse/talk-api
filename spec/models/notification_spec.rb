require 'spec_helper'

RSpec.describe Notification, type: :model do
  it_behaves_like 'a sectioned model'
  context 'validating' do
    it 'should require a user' do
      without_target = build :notification, user: nil
      expect(without_target).to fail_validation user: "can't be blank"
    end
    
    it 'should require a url' do
      without_url = build :notification, url: nil
      expect(without_url).to fail_validation url: "can't be blank"
    end
    
    it 'should require a message' do
      without_message = build :notification, message: nil
      expect(without_message).to fail_validation message: "can't be blank"
    end
    
    it 'should require a section' do
      without_section = build :notification, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
    
    it 'should require a subscription' do
      without_subscription = build :notification, subscription: nil
      expect(without_subscription).to fail_validation subscription: "can't be blank"
    end
  end
  
  context 'creating' do
    let(:notification){ create :notification }
    it 'should publish' do
      expect(NotificationWorker).to receive :perform_async
      notification.run_callbacks :commit
    end
  end
  
  it_behaves_like 'an expirable model' do
    let!(:fresh){ create_list :notification, 2 }
    let!(:stale){ create_list :notification, 2, created_at: 1.year.ago.utc }
  end
end
