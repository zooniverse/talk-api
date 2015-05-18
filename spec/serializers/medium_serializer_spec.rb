require 'spec_helper'

RSpec.describe MediumSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: [:id, :href, :content_type, :media_type, :external_link] do
    subject{ json }
    
    its([:media_type]){ is_expected.to eql instance.type }
    
    context 'with links' do
      subject{ json[:links] }
      its([:linked]){ is_expected.to eql instance.linked_id.to_s }
      its([:linked_type]){ is_expected.to eql 'Subject' }
    end
  end
end
