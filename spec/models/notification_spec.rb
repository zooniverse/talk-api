require 'spec_helper'

RSpec.describe Notification, type: :model do
  context 'validating' do
    it 'should require a user' do
      without_target = build :notification, user: nil
      expect(without_target).to fail_validation user: "can't be blank"
    end
  end
end
