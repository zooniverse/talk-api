require 'spec_helper'

RSpec.describe AnnouncementSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all do
    it_behaves_like 'a serializer with embedded attributes', relations: [:project]
  end
end
