require 'spec_helper'

RSpec.describe UserSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, excluding: [:email]

  it_behaves_like 'a moderatable serializer' do
    let(:not_logged_in_actions){ [] }
    let(:logged_in_actions){ [:report] }
    let(:moderator_actions){ [:report, :watch, :ignore] }
    let(:admin_actions){ [:report, :watch, :ignore] }
  end
end
