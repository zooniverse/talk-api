require 'spec_helper'

RSpec.describe BlockedUserSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['blocked_users'] }

    with 'properties .blocked_users' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:required){ is_expected.to eql %w(user_id blocked_user_id) }

      with :properties do
        its(:user_id){ is_expected.to eql id_schema }
        its(:blocked_user_id){ is_expected.to eql id_schema }
      end
    end
  end

  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['blocked_users'] }

    with 'properties .blocked_users' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:properties){ is_expected.to eql({ }) }
    end
  end
end
