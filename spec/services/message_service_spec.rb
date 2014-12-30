require 'spec_helper'

RSpec.describe MessageService, type: :service do
  it_behaves_like 'a service', Message do
    let(:conversation){ create :conversation_with_messages, user: current_user }
    
    let(:params) do
      {
        messages: {
          body: 'works',
          conversation_id: conversation.id
        }
      }
    end
  end
end
