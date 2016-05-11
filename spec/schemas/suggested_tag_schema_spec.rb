require 'spec_helper'

RSpec.describe SuggestedTagSchema, type: :schema do
  shared_examples_for 'an suggested_tag schema' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['suggested_tags'] }

    with 'properties .suggested_tags' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }

      with :properties do
        its(:name){ is_expected.to eql type: 'string' }
        its(:section){ is_expected.to eql type: 'string' }
      end
    end
  end

  describe '#create' do
    let(:schema_method){ :create }
    it_behaves_like 'an suggested_tag schema'

    with 'properties .suggested_tags' do
      its(:required){ is_expected.to eql %w(name section) }
    end
  end

  describe '#update' do
    let(:schema_method){ :update }
    it_behaves_like 'an suggested_tag schema'

    with 'properties .suggested_tags' do
      its(:required){ is_expected.to be_nil }
    end
  end
end
