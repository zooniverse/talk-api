require 'spec_helper'

RSpec.describe MessageService, type: :service do
  it_behaves_like 'a service', Message do
    let(:conversation){ create :conversation_with_messages, user: current_user }
    
    let(:create_params) do
      {
        messages: {
          body: 'works',
          conversation_id: conversation.id
        }
      }
    end
    
    it_behaves_like 'a service creating', Message
    context 'creating the message' do
      before(:each){ service.create }
      subject{ service.resource }
      its(:user){ is_expected.to eql current_user }
    end
  end
end
