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
        its(:parent_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }, { 'type' => 'null' }] }
        its(:subject_default){ is_expected.to eql type: 'boolean' }
        
        with :permissions do
          its(:type){ is_expected.to eql 'object' }
          its(:required){ is_expected.to eql %w(read write) }
          
          with :properties do
            its(:read){ is_expected.to eql enum: %w(all team moderator admin) }
            its(:write){ is_expected.to eql enum: %w(all team moderator admin) }
          end
        end
      end
    end
  end
  
  describe '#create' do
    let(:schema_method){ :create }
    it_behaves_like 'a board schema'
    
    with 'properties .boards' do
      its(:required){ is_expected.to eql %w(title description section permissions) }
      
      with :properties do
        its(:section){ is_expected.to eql type: 'string' }
      end
    end
  end
  
  describe '#update' do
    let(:schema_method){ :update }
    it_behaves_like 'a board schema'
    
    with 'properties .boards' do
      its(:required){ is_expected.to be_nil }
      
      with :properties do
        its(:section){ is_expected.to be nil }
      end
    end
  end
end
