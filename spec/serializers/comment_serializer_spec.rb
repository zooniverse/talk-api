require 'spec_helper'

RSpec.describe CommentSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:discussion] do
    let(:focus){ create :subject }
    let(:model_instance){ create :comment_for_focus, focus: focus }
    let(:json){ CommentSerializer.resource(id: model_instance.id)[:comments].first }
    subject{ json }
    
    its([:user_display_name]){ is_expected.to eql model_instance.user.display_name }
    it{ is_expected.to include :focus }
    its([:links]){ is_expected.to eql focus: focus.id.to_s, focus_type: 'Subject', discussion: model_instance.discussion_id.to_s }
    
    context 'with a focus' do
      subject{ json[:focus] }
      its([:href]){ is_expected.to eql "/subjects/#{ focus.id }" }
      it{ is_expected.to have_key :id }
      it{ is_expected.to have_key :links }
      it{ is_expected.to have_key :zooniverse_id }
      it{ is_expected.to have_key :metadata }
      it{ is_expected.to have_key :locations }
      it{ is_expected.to have_key :created_at }
      it{ is_expected.to have_key :updated_at }
      it{ is_expected.to have_key :project_id }
    end
  end
  
  it_behaves_like 'a moderatable serializer' do
    let(:not_logged_in_actions){ [] }
    let(:logged_in_actions){ [:report] }
    let(:moderator_actions){ [:report, :destroy, :ignore] }
    let(:admin_actions){ [:report, :destroy, :ignore] }
  end
end
