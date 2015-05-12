require 'spec_helper'

RSpec.describe RoleSerializer, type: :serializer do
  let(:object){ create :role }
  it_behaves_like 'a talk serializer', exposing: :all, including: [:user]
end
