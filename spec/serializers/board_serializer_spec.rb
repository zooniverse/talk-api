require 'spec_helper'

RSpec.describe BoardSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, excluding: [:permissions], including: [:discussions]
end
