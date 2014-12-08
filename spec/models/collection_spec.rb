require 'spec_helper'

RSpec.describe Collection, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a user' do
      without_user = build :collection, user: nil
      expect(without_user).to_not be_valid
      expect(without_user).to fail_validation user: "can't be blank"
    end
  end
end
