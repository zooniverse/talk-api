require 'spec_helper'

RSpec.describe Discussion, type: :model do
  context 'validating' do
    it 'should require a title' do
      without_title = build :discussion, title: nil
      expect(without_title).to_not be_valid
      expect(without_title).to fail_validation title: "can't be blank"
    end
    
    it 'should limit title length' do
      short_title = build :discussion, title: 'a'
      expect(short_title).to fail_validation title: 'too short'
      long_title = build :discussion, title: '!' * 200
      expect(long_title).to fail_validation title: 'too long'
    end
    
    it 'should require a user' do
      without_user = build :discussion, user_id: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
  end
  
  context 'creating' do
    it 'should denormalize the user name' do
      discussion = create :discussion
      expect(discussion.user_name).to eq discussion.user.name
    end
  end
end
