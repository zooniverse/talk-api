require 'spec_helper'

RSpec.describe UserConversation, type: :model do
  it_behaves_like 'a subscribable model'

  context 'validating' do
    it 'should require a user' do
      without_user = build :user_conversation, user_id: nil
      expect(without_user).to fail_validation
    end
  end

  context 'destroying' do
    include_context 'existing conversation'

    it 'should not destroy the conversation if a user conversation still exists' do
      expect {
        conversation.user_conversations.first.destroy
        conversation.reload
      }.to_not raise_exception
    end

    it 'destroy the conversation if no user conversations exist' do
      expect {
        conversation.user_conversations.map &:destroy
        conversation.reload
      }.to raise_exception ActiveRecord::RecordNotFound
    end
  end

  context 'creating' do
    let(:conversation){ create :conversation }
    let(:user){ create :user }

    it 'should update the conversation partcipants' do
      expect {
        create :user_conversation, conversation: conversation, user: user
      }.to change {
        conversation.reload.participant_ids
      }.from([]).to [user.id]
    end
  end
end
