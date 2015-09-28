require 'rspec'

RSpec.shared_examples_for 'a serializer with embedded attributes' do |relations: []|
  let!(:project) do
    Project.find_by_id(model_instance.project_id) ||
    create(:project, id: model_instance.project_id)
  end
  
  if relations.include?(:board)
    describe '#board_attributes' do
      subject{ json }
      its([:board_comments_count]){ is_expected.to eql model_instance.board.reload.comments_count }
      its([:board_description]){ is_expected.to eql model_instance.board.description }
      its([:board_discussions_count]){ is_expected.to eql model_instance.board.reload.discussions_count }
      its([:board_id]){ is_expected.to eql model_instance.board.id.to_s }
      its([:board_parent_id]){ is_expected.to eql model_instance.board.parent_id.to_s }
      its([:board_subject_default]){ is_expected.to eql model_instance.board.subject_default }
      its([:board_title]){ is_expected.to eql model_instance.board.title }
      its([:board_users_count]){ is_expected.to eql model_instance.board.reload.users_count }
    end
  end
  
  if relations.include?(:discussion)
    describe '#discussion_attributes' do
      subject{ json }
      its([:discussion_comments_count]){ is_expected.to eql model_instance.discussion.reload.comments_count }
      its([:discussion_subject_default]){ is_expected.to eql model_instance.discussion.subject_default }
      its([:discussion_title]){ is_expected.to eql model_instance.discussion.title }
      its([:discussion_updated_at]){ is_expected.to be_within(1.second).of model_instance.discussion.reload.updated_at }
      its([:discussion_users_count]){ is_expected.to eql model_instance.discussion.reload.users_count }
    end
  end
  
  if relations.include?(:project)
    describe '#project_attributes' do
      subject{ json }
      its([:project_slug]){ is_expected.to eql model_instance.project.slug }
    end
  end
end
