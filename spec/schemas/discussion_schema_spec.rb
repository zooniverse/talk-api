require 'spec_helper'

RSpec.describe DiscussionSchema, type: :schema do
  shared_examples_for 'discussion schema' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['discussions'] }
    
    with 'properties .discussions' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        with :title do
          its(:type){ is_expected.to eql 'string' }
          its(:minLength){ is_expected.to eql 3 }
          its(:maxLength){ is_expected.to eql 140 }
        end
        
        its(:board_id){ is_expected.to eql id_schema }
        
        its(:sticky){ is_expected.to eql type: 'boolean', default: false }
        its(:sticky_position){ is_expected.to eql oneOf: [{ 'type' => 'number' }, { 'type' => 'null' }] }
      end
    end
  end
  
  describe '#create' do
    let(:schema_method){ :create }
    include_context 'discussion schema'
    
    with 'properties .discussions' do
      its(:required){ is_expected.to eql %w(title board_id user_id comments) }
      
      with :properties do
        its(:subject_default){ is_expected.to eql type: 'boolean' }
      end
      
      with 'properties .comments' do
        its(:type){ is_expected.to eql 'array' }
        its(:minItems){ is_expected.to eql 1 }
        
        with :items do
          its(:type){ is_expected.to eql 'object' }
          its(:required){ is_expected.to eql %w(user_id body) }
          
          with :properties do
            its(:user_id){ is_expected.to eql id_schema }
            its(:category){ is_expected.to eql type: 'string' }
            its(:body){ is_expected.to eql type: 'string' }
            it_behaves_like 'a focus schema'
          end
        end
      end
    end
  end
  
  describe '#update' do
    let(:schema_method){ :update }
    include_context 'discussion schema'
    with 'properties .discussions .properties' do
      its(:locked){ is_expected.to eql type: 'boolean' }
    end
  end
end
