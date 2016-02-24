require 'spec_helper'

RSpec.describe Role, type: :model do
  context 'validating' do
    it 'should require a user' do
      without_user = build :role, user: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end

    it 'should prevent duplicates' do
      role = create :role
      duplicate = build :role, user: role.user, section: role.section, name: role.name
      expect(duplicate).to fail_validation user_id: 'Role already exists for this user and section'
    end
  end
end
