require 'spec_helper'

RSpec.describe ConversationSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['conversations'] }
    
    with 'properties .conversations' do
      its(:type){ is_expected.to eql 'object' }
      its(:required){ is_expected.to eql %w(title user_id body recipient_ids) }
      
      with :properties do
        its(:title){ is_expected.to eql type: 'string' }
        its(:user_id){ is_expected.to eql type: 'integer' }
        its(:body){ is_expected.to eql type: 'string' }
        
        with :recipient_ids do
          its(:type){ is_expected.to eql 'array' }
          its(:uniqueItems){ is_expected.to eql true }
          its(:minItems){ is_expected.to eql 1 }
          its(:items){ is_expected.to eql type: 'integer' }
        end
      end
    end
  end
end
