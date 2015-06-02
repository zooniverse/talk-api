require 'spec_helper'

RSpec.describe SubscriptionSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:notifications]
end
