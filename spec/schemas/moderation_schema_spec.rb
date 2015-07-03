require 'spec_helper'

RSpec.describe ModerationSchema, type: :schema do
  shared_examples_for 'moderation schema reports' do
    with :reports do
      its(:type){ is_expected.to eql 'array' }
      its(:minItems){ is_expected.to eql 1 }
      
      with :items do
        its(:type){ is_expected.to eql 'object' }
        its(:required){ is_expected.to eql ['user_id', 'message'] }
        
        with :properties do
          its(:user_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }] }
          its(:message){ is_expected.to eql type: 'string' }
        end
      end
    end
  end
  
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['moderations'] }
    
    with 'properties .moderations' do
      its(:type){ is_expected.to eql 'object' }
      its(:required){ is_expected.to eql ['section', 'target_id', 'target_type'] }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        include_context 'moderation schema reports'
        its(:section){ is_expected.to eql type: 'string' }
        its(:target_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }] }
        its(:target_type){ is_expected.to eql type: 'string' }
      end
    end
  end
  
  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['moderations'] }
    
    with 'properties .moderations' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        include_context 'moderation schema reports'
        
        with :actions do
          its(:type){ is_expected.to eql 'array' }
          its(:minItems){ is_expected.to eql 1 }
          
          with :items do
            its(:type){ is_expected.to eql 'object' }
            its(:required){ is_expected.to eql ['user_id', 'message'] }
            
            with :properties do
              its(:user_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }] }
              its(:message){ is_expected.to eql type: 'string' }
              
              with :action do
                its(:type){ is_expected.to eql 'string' }
                its(:enum){ is_expected.to match_array ['destroy', 'ignore', 'watch'] }
              end
            end
          end
        end
      end
    end
  end
end
