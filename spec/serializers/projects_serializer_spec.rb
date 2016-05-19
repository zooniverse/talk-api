require 'spec_helper'

RSpec.describe ProjectSerializer, type: :serializer do
  let(:object){ create :project }
  it_behaves_like 'a talk serializer', exposing: :all
end
