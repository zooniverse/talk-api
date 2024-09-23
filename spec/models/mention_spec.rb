require 'rspec'

RSpec.describe Mention, type: :model do
  let(:focus){ create :subject }

  describe 'creating' do
    let(:project){ create :project }
    let(:project_board){ create :board, section: "project-#{ project.id }" }
    let(:project_discussion){ create :discussion, board: project_board }
    let(:project_comment){ create :comment, discussion: project_discussion }

    let(:section_board){ create :board, section: 'zooniverse' }
    let(:section_discussion){ create :discussion, board: section_board }
    let(:section_comment){ create :comment, discussion: section_discussion }

    context 'with a project' do
      subject{ create :mention, comment: project_comment }
      its(:section){ is_expected.to eql "project-#{ project.id }" }
      its(:project_id){ is_expected.to eql project.id }
      its(:board_id){ is_expected.to eql project_board.id }
    end

    context 'without a project' do
      subject{ create :mention, comment: section_comment }
      its(:section){ is_expected.to eql 'zooniverse' }
      its(:project_id){ is_expected.to be_nil }
      its(:board_id){ is_expected.to eql section_board.id }
    end
  end

  describe '#notify_later' do
    it 'should queue the notification' do
      project_board = create :board, section: "project-#{ focus.project.id
      project_discussion = create :discussion, board: project_board
      project_comment = create :comment, discussion: project_discussion
      mention = build :mention, mentionable: focus, comment: project_comment
      expect(MentionWorker).to receive(:perform_async)
      mention.save!
    end
  end

  describe '#notify_mentioned' do
    it 'should notify of the mention' do
      subject_mentioned =
      mention = create :mention, mentionable: focus
      expect(focus).to receive(:mentioned_by).with mention.comment
      mention.notify_mentioned
    end
  end
end
