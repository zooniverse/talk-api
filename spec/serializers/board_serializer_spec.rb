require 'spec_helper'

RSpec.describe BoardSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, excluding: [:permissions], including: [:discussions, :parent, :sub_boards] do
    let(:parent){ create :board }
    let(:model_instance){ create :board_with_subboards, parent: parent }
  end
end
