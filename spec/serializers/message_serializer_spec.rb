require 'spec_helper'

RSpec.describe MessageSerializer, type: :serializer do
  let(:conversation){ create :conversation_with_messages }
  let(:object){ conversation.messages.first }
  it_behaves_like 'a talk serializer', exposing: :all, including: [:conversation, :user]
end
