require 'spec_helper'

RSpec.describe SubjectSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:mentions, :comments] do
    context 'serializing locations' do
      subject{ json[:locations] }
      its(:length){ is_expected.to eql 2 }
      its(:first){ is_expected.to include :href }
    end
  end
end
