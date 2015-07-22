require 'spec_helper'

RSpec.describe DataRequestSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all
end
