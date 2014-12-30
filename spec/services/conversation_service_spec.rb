require 'spec_helper'

RSpec.describe ConversationService, type: :service do
  it_behaves_like 'a service', Conversation do
    let(:params) do
      {
        conversations: {
          title: 'works',
          body: 'a message',
          recipient_ids: create_list(:user, 2).collect(&:id)
        }
      }
    end
  end
end
