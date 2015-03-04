require 'spec_helper'

RSpec.describe CollectionSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:mentions, :comments]
end
