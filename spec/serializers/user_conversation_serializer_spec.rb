require 'spec_helper'

RSpec.describe UserConversationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:user, :conversation]
end
