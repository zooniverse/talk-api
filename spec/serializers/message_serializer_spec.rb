require 'spec_helper'

RSpec.describe MessageSerializer, type: :serializer do
  let(:conversation){ create :conversation_with_messages }
  let(:object){ conversation.messages.first }
  it_behaves_like 'a talk serializer', exposing: :all, including: [:conversation]
  
  it 'should sideload sender' do
    json = MessageSerializer.resource id: object.id
    message_json = json[:messages].first
    expect(message_json[:sender][:id]).to eql object.sender.id
    expect(message_json[:recipient][:id]).to eql object.recipient.id
  end
end
