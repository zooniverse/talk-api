require 'spec_helper'

RSpec.describe SubscriptionPreferenceSchema, type: :schema do
  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql %w(subscription_preferences) }
    
    with 'properties .subscription_preferences' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:required){ is_expected.to_not be_present }
      
      with :properties do
        its(:enabled){ is_expected.to eql type: 'boolean' }
        
        with :email_digest do
          its(:type){ is_expected.to eql 'string' }
          its(:enum){ is_expected.to match_array %w(immediate daily weekly) }
        end
      end
    end
  end
end
