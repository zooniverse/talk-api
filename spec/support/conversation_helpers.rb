RSpec.shared_context 'existing conversation' do
  let!(:conversation){ create :read_conversation }
  let(:sender){ conversation.messages.first.sender }
  let(:recipient){ conversation.messages.first.recipient }
  let(:sender_conversation){ conversation.user_conversations.where(user_id: sender.id).first }
  let(:recipient_conversation){ conversation.user_conversations.where(user_id: recipient.id).first }
end
