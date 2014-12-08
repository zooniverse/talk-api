require 'spec_helper'

RSpec.shared_context 'existing conversation' do
  let(:user){ create :user }
  let(:recipients){ create_list :user, 2 }
  let!(:conversation){ create :read_conversation, user: user, recipients: recipients }
  let(:user_conversation){ conversation.user_conversations.where(user_id: user.id).first }
  let(:recipient_conversations){ conversation.user_conversations.where.not(user_id: user.id).all }
end
