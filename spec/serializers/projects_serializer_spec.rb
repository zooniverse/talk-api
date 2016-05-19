require 'spec_helper'

RSpec.describe ProjectSerializer, type: :serializer do
  let(:object){ create :project }
  it_behaves_like 'a talk serializer', exposing: [
    :id, :display_name, :slug, :private,
    :launch_approved, :launched_row_order
  ]
end
