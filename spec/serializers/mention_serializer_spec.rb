require 'spec_helper'

RSpec.describe MentionSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:comment, :user]
end
