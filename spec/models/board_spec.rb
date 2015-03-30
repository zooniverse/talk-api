require 'spec_helper'

RSpec.describe Board, type: :model do
  it_behaves_like 'a searchable interface'
  it_behaves_like 'a searchable model' do
    let(:searchable){ create :board, permissions: { read: 'all' } }
    let(:unsearchable){ create :board, permissions: { read: 'admin' } }
  end
  
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
      expect{ board.reload.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
      board.discussions.destroy_all
      expect{ board.destroy! }.to_not raise_error
    end
  end
end
