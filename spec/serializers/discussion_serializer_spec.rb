require 'spec_helper'

RSpec.describe DiscussionSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:comments, :board, :user] do
    subject{ json }
    its([:user_display_name]){ is_expected.to eql model_instance.user.display_name }
  end
  
  it_behaves_like 'a moderatable serializer' do
    let(:not_logged_in_actions){ [] }
    let(:logged_in_actions){ [:report] }
    let(:moderator_actions){ [:report, :watch, :destroy, :ignore] }
    let(:admin_actions){ [:report, :watch, :destroy, :ignore] }
  end
end
