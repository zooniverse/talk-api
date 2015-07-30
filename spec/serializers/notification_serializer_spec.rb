require 'spec_helper'

RSpec.describe NotificationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:subscription] do
    it_behaves_like 'a serializer with embedded attributes', relations: [:project]
  end
end
