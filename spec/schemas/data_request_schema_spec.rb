require 'spec_helper'

RSpec.describe DataRequestSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['data_requests'] }

    with 'properties .data_requests' do
      its(:type){ is_expected.to eql 'object' }
      its(:required){ is_expected.to eql %w(user_id section kind) }
      its(:additionalProperties){ is_expected.to be false }

      with :properties do
        its(:user_id){ is_expected.to eql id_schema }
        its(:section){ is_expected.to eql type: 'string' }
        its(:kind){ is_expected.to eql type: 'string', enum: %w(tags votable_tags comments) }
      end
    end
  end

  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['data_requests'] }

    with 'properties .data_requests' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:properties){ is_expected.to eql({ }) }
    end
  end
end
