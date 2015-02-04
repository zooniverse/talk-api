require 'spec_helper'

RSpec.describe BoardSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, excluding: [:permissions], including: [:discussions] do
    let(:model_instance){ create :board_with_subboards }
  end
end
