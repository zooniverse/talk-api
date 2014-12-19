require 'spec_helper'

RSpec.describe UserSchema, type: :schema do
  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['users'] }
    
    with 'properties .users' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      
      with 'properties .preferences' do
        its(:type){ is_expected.to eql 'object' }
        its(:additionalProperties){ is_expected.to be true }
      end
    end
  end
end
