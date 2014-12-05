require 'spec_helper'

RSpec.describe ConversationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:messages]
end
