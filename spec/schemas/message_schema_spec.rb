require 'spec_helper'

RSpec.describe MessageSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['messages'] }
    
    with 'properties .messages' do
      its(:type){ is_expected.to eql 'object' }
      its(:required){ is_expected.to eql %w(user_id conversation_id body) }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        its(:user_id){ is_expected.to eql type: 'integer' }
        its(:conversation_id){ is_expected.to eql type: 'integer' }
        its(:body){ is_expected.to eql type: 'string' }
      end
    end
  end
end
