require 'spec_helper'

RSpec.describe NotificationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all
end
