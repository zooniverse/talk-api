require 'spec_helper'

RSpec.describe ConversationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:messages]
  
  it_behaves_like 'a moderatable serializer' do
    let(:record){ create :conversation_with_messages }
    # actually, only participants
    let(:not_logged_in_actions){ [:report] }
    let(:logged_in_actions){ [:report] }
    
    let(:moderator_actions){ [:report, :destroy, :ignore] }
    let(:admin_actions){ [:report, :destroy, :ignore] }
  end
end
