require 'spec_helper'

RSpec.describe BlockedUser, type: :model do
  context 'validating' do
    it 'should require a user' do
      without_user = build :blocked_user, user: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a blocked_user' do
      without_blocked_user = build :blocked_user, blocked_user: nil
      expect(without_blocked_user).to fail_validation blocked_user: "can't be blank"
    end
  end
end
