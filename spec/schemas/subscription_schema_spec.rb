require 'spec_helper'

RSpec.describe SubscriptionSchema, type: :schema do
  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql %w(subscriptions) }
    
    with 'properties .subscriptions' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:required){ is_expected.to match_array %w(enabled) }
      
      with :properties do
        its(:enabled){ is_expected.to eql type: 'boolean' }
      end
    end
  end
end
