require 'spec_helper'

RSpec.describe SuggestedTagSerializer, type: :serializer do
  let(:object){ create :suggested_tag }
  it_behaves_like 'a talk serializer', exposing: :all
end
