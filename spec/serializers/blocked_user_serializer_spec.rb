require 'spec_helper'

RSpec.describe BlockedUserSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all
end
