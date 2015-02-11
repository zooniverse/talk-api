require 'spec_helper'

RSpec.describe BoardSchema, type: :schema do
  shared_examples_for 'a board schema' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['boards'] }
    
    with 'properties .boards' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        its(:title){ is_expected.to eql type: 'string' }
        its(:description){ is_expected.to eql type: 'string' }
        its(:parent_id){ is_expected.to eql oneOf: [{ 'type' => 'integer' }, 'type' => 'null' ] }
      end
    end
  end
  
  describe '#create' do
    let(:schema_method){ :create }
    it_behaves_like 'a board schema'
    
    with 'properties .boards' do
      its(:required){ is_expected.to eql %w(title description section) }
      
      with :properties do
        its(:section){ is_expected.to eql type: 'string' }
      end
    end
  end
  
  describe '#update' do
    let(:schema_method){ :update }
    it_behaves_like 'a board schema'
    
    with 'properties .boards .properties' do
      its(:section){ is_expected.to be nil }
    end
  end
end
