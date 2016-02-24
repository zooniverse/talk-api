require 'spec_helper'

RSpec.describe CommentSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, excluding: [:user_ip] do
    let(:replied_to){ create :comment }
    let(:object){ create :comment, reply: replied_to }
    let(:json){ CommentSerializer.resource(id: model_instance.id)[:comments].first }
    subject{ json }
    it_behaves_like 'a serializer with embedded attributes', relations: [:project, :discussion, :board]

    its([:user_display_name]){ is_expected.to eql model_instance.user.display_name }
    its([:reply_user_id]){ is_expected.to eql replied_to.user.id }
    its([:reply_user_login]){ is_expected.to eql replied_to.user.login }
    its([:reply_user_display_name]){ is_expected.to eql replied_to.user.display_name }
  end

  it_behaves_like 'a moderatable serializer' do
    let(:not_logged_in_actions){ [] }
    let(:logged_in_actions){ [:report] }
    let(:moderator_actions){ [:report, :destroy, :ignore] }
    let(:admin_actions){ [:report, :destroy, :ignore] }
  end
end
