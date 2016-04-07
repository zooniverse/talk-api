require 'spec_helper'

RSpec.describe BlockedUser, type: :model do
  let(:user1){ create :user }
  let(:user2){ create :user }
  let(:user1_blocks){ create_list :blocked_user, 2, user: user1 }
  let(:user2_blocks){ create_list :blocked_user, 2, user: user2 }

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

  describe '.blocked_by' do
    before(:each){ user1_blocks; user2_blocks }
    subject{ BlockedUser.blocked_by user1.id }
    it{ is_expected.to match_array user1_blocks }
  end

  describe '.blocked' do
    before(:each){ user1_blocks; user2_blocks }
    let(:blocked_ids){ user1_blocks.map &:blocked_user_id }
    subject{ BlockedUser.blocking blocked_ids }
    it{ is_expected.to match_array user1_blocks }
  end
end
