require 'spec_helper'

RSpec.describe SubscriptionSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql %w(subscriptions) }
    
    with 'properties .subscriptions' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:required){ is_expected.to match_array %w(source_id source_type category user_id) }
      
      with :properties do
        its(:enabled){ is_expected.to eql type: 'boolean', default: true }
        its(:source_id){ is_expected.to eql id_schema }
        its(:user_id){ is_expected.to eql id_schema }
        its(:source_type){ is_expected.to eql type: 'string', enum: %w(Board Discussion) }
        its(:category){ is_expected.to eql type: 'string', enum: %w(started_discussions followed_discussions) }
      end
    end
  end
  
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
