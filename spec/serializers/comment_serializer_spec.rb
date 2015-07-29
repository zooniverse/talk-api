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
    
    describe '#board_attributes' do
      its([:board_comments_count]){ is_expected.to eql model_instance.board.comments_count }
      its([:board_description]){ is_expected.to eql model_instance.board.description }
      its([:board_discussions_count]){ is_expected.to eql model_instance.board.discussions_count }
      its([:board_id]){ is_expected.to eql model_instance.board.id.to_s }
      its([:board_parent_id]){ is_expected.to eql model_instance.board.parent_id.to_s }
      its([:board_subject_default]){ is_expected.to eql model_instance.board.subject_default }
      its([:board_title]){ is_expected.to eql model_instance.board.title }
      its([:board_users_count]){ is_expected.to eql model_instance.board.users_count }
    end
    
    describe '#discussion_attributes' do
      its([:discussion_comments_count]){ is_expected.to eql model_instance.discussion.comments_count }
      its([:discussion_subject_default]){ is_expected.to eql model_instance.discussion.subject_default }
      its([:discussion_title]){ is_expected.to eql model_instance.discussion.title }
      its([:discussion_updated_at]){ is_expected.to be_within(1.second).of model_instance.discussion.updated_at }
      its([:discussion_users_count]){ is_expected.to eql model_instance.discussion.users_count }
    end
  end
  
  it_behaves_like 'a moderatable serializer' do
    let(:not_logged_in_actions){ [] }
    let(:logged_in_actions){ [:report] }
    let(:moderator_actions){ [:report, :destroy, :ignore] }
    let(:admin_actions){ [:report, :destroy, :ignore] }
  end
end
