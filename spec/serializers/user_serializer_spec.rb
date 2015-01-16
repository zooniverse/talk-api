require 'spec_helper'

RSpec.describe UserSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, excluding: [:email]
end
