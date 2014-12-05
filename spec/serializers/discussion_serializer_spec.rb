require 'spec_helper'

RSpec.describe DiscussionSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:comments, :board, :user]
end
