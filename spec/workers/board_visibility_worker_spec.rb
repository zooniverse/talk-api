require 'spec_helper'

RSpec.describe BoardVisibilityWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe '#perform' do
    let(:board){ create :board_with_discussions, discussion_count: 2 }

    it 'should update the board' do
      allow(Board).to receive(:find).with(board.id).and_return board
      expect(board).to receive(:each_discussion_and_comment) do |&block|
        expect(block).to eql :action.to_proc
      end
      subject.perform board.id, :action
    end
  end
end
