require 'spec_helper'

RSpec.describe ModerationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all
end
