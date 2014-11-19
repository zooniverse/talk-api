require 'spec_helper'

RSpec.describe Board, type: :model do
  context 'validating' do
    it 'should require a title' do
      without_title = build :board, title: nil
      expect(without_title).to_not be_valid
      expect(without_title).to fail_validation title: "can't be blank"
    end
    
    it 'should require a title' do
      without_description = build :board, description: nil
      expect(without_description).to_not be_valid
      expect(without_description).to fail_validation description: "can't be blank"
    end
    
    it 'should restrict deletion with dependent discussions' do
      board = create :board_with_discussions
      expect{ board.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
      board.discussions.destroy_all
      expect{ board.destroy! }.to_not raise_error
    end
  end
end
