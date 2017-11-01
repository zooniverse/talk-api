require 'spec_helper'

RSpec.describe RoleSchema, type: :schema do
  shared_examples_for 'a role schema' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['roles'] }

    with 'properties .roles' do
      its(:additionalProperties){ is_expected.to be false }

      with :properties do
        its(:is_shown){ is_expected.to eql type: 'boolean', default: true }

        with :name do
          its(:type){ is_expected.to eql 'string' }
          its(:enum){ is_expected.to eql %w(admin moderator scientist team translator) }
        end
      end
    end
  end

  describe '#create' do
    let(:schema_method){ :create }
    it_behaves_like 'a role schema'

    with 'properties .roles' do
      its(:required){ is_expected.to eql %w(user_id section name) }

      with :properties do
        its(:user_id){ is_expected.to eql id_schema }
        its(:section){ is_expected.to eql type: 'string' }
      end
    end
  end

  describe '#update' do
    let(:schema_method){ :update }
    it_behaves_like 'a role schema'

    with 'properties .roles' do
      its(:required){ is_expected.to eql %w(name) }

      with :properties do
        its(:user_id){ is_expected.to be nil }
      end
    end
  end
end
