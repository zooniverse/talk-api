require 'spec_helper'

RSpec.describe MessagePolicy, type: :policy do
  let(:user){ }
  let(:record){ create :message }
  subject{ MessagePolicy.new user, record }

  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end

  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end

  context 'with an unconfirmed user' do
    let(:user){ create :user, confirmed_at: nil }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end

  context 'with a participant' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end

  describe '#participant?' do
    let(:user) { record.user }
    let(:other_user) { create :user }

    it 'returns false for participant? when user is not logged in' do
      expect(MessagePolicy.new(nil, record).participant?).to be false
    end

    context 'when the record is persisted' do
      it 'returns true for participant? when user is a participant' do
        expect(MessagePolicy.new(user, record).participant?).to be true
      end

      it 'returns false for participant? when user is not a participant' do
        expect(MessagePolicy.new(other_user, record).participant?).to be false
      end
    end

    context 'when the record is not persisted but has a conversation' do
      let(:non_persisted_message) { build :message, conversation: record.conversation }

      it 'returns true for participant? when user is a participant' do
        expect(MessagePolicy.new(user, non_persisted_message).participant?).to be true
      end

      it 'returns false for participant? when user is not part of the conversation' do
        expect(MessagePolicy.new(other_user, non_persisted_message).participant?).to be false
      end
    end

    context 'when all records belong to the user' do
      let(:message1) { create :message, user: user }
      let(:message2) { create :message, user: user }
      let(:messages) { [message1, message2] }

      it 'returns true for participant? when all messages belong to the user' do
        expect(MessagePolicy.new(user, messages).participant?).to be true
      end
    end

    context 'when at least one message is not associated with the user' do
      let(:message1) { create :message, user: user }
      let(:message2) { create :message, user: other_user }
      let(:messages) { [message1, message2] }

      it 'returns false for participant? when at least one message is not associated with the user' do
        expect(MessagePolicy.new(user, messages).participant?).to be false
        expect(MessagePolicy.new(user, messages.reverse).participant?).to be false
      end
    end
  end

  context 'with a moderator' do
    let(:user){ create :moderator, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with an admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with scope' do
    let!(:other_records){ create_list :message, 2 }
    let(:user){ create :user }
    let(:records){ create_list :message, 2, user: user }
    subject{ MessagePolicy::Scope.new(user, Message).resolve }

    it{ is_expected.to match_array records }
  end
end
