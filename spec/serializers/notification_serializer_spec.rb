require 'spec_helper'

RSpec.describe NotificationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:subscription] do
    it_behaves_like 'a serializer with embedded attributes', relations: [:project]

    context 'with a source' do
      subject{ json }
      it{ is_expected.to include :source }
      its([:source]){ is_expected.to include :id => model_instance.source.id.to_s }
    end
  end
end
