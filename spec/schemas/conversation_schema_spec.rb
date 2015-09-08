require 'spec_helper'

RSpec.describe ConversationSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['conversations'] }
    
    with 'properties .conversations' do
      its(:type){ is_expected.to eql 'object' }
      its(:required){ is_expected.to eql %w(title user_id body recipient_ids) }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        its(:title){ is_expected.to eql type: 'string' }
        its(:user_id){ is_expected.to eql id_schema }
        its(:body){ is_expected.to eql type: 'string' }
        
        with :recipient_ids do
          its(:type){ is_expected.to eql 'array' }
          its(:uniqueItems){ is_expected.to eql true }
          its(:minItems){ is_expected.to eql 1 }
          its(:items){ is_expected.to eql id_schema }
        end
      end
    end
  end
  
  describe '#update' do
    let(:schema_method){ :update }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['conversations'] }
    
    with 'properties .conversations' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }
      its(:properties){ is_expected.to eql({ }) }
    end
  end
end
