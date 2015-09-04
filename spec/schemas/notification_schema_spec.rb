require 'spec_helper'

RSpec.describe NotificationSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['notifications'] }
    
    with 'properties .notifications' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:properties){ is_expected.to eql({ }) }
    end
  end
  
  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['notifications'] }
    
    with 'properties .notifications' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        its(:delivered){ is_expected.to eql type: 'boolean' }
      end
    end
  end
end
