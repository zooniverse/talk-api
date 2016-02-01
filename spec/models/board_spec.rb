require 'spec_helper'

RSpec.describe Board, type: :model do
  it_behaves_like 'a sectioned model'
  it_behaves_like 'a subscribable model'
  it_behaves_like 'a searchable interface'
  it_behaves_like 'a searchable model' do
    let(:searchable){ create :board }
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
    
    it 'should cascade deletion to dependent discussions' do
      board = create :board_with_discussions
      expect{ board.destroy.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(Discussion.where(board_id: board.id)).to_not exist
    end
  end
  
  describe '#latest_discussion' do
    let(:board){ create :board }
    let!(:older){ create :discussion, board: board, last_comment_created_at: 3.hours.ago.utc }
    let!(:newer){ create :discussion, board: board, last_comment_created_at: 2.hours.ago.utc }
    
    it 'should find the newest comment' do
      expect(board.latest_discussion).to eql newer
    end
  end
  
  describe '#subject_default' do
    let!(:default_board){ create :board, section: 'project-1', subject_default: true }
    
    it 'should not allow other default boards in the section' do
      expect {
        create :board, section: 'project-1', subject_default: true
      }.to raise_error ActiveRecord::RecordNotUnique
    end
    
    it 'should be scoped to section' do
      expect {
        create :board, section: 'project-2', subject_default: true
      }.to_not raise_error
    end
  end
  
  describe '#cascade_searchable_later' do
    let(:board){ create :board_with_discussions, discussion_count: 2 }
    let(:children){ board.discussions.all.to_a + board.comments.all.to_a }
    let(:comments) do
      board.discussions.collect do |discussion|
        create_list :comment, discussion: discussion
      end.flatten
    end
    
    context 'when changing from public to private' do
      it 'should initially be searchable' do
        children.each do |child|
          expect(child.searchable).to be_present
        end
      end
      
      it 'should remove all searchable children' do
        board.permissions['read'] = 'private'
        expect(BoardVisibilityWorker).to receive(:perform_in).with 1.second, board.id, :destroy_searchable
        board.save
      end
    end
    
    context 'when changing from private to public' do
      let(:board){ create :board_with_discussions, discussion_count: 2, permissions: { read: 'admin' } }
      
      it 'should initially be unsearchable' do
        children.each do |child|
          expect(child.searchable).to_not be_present
        end
      end
      
      it 'should add all searchable children' do
        board.permissions['read'] = 'all'
        expect(BoardVisibilityWorker).to receive(:perform_in).with 1.second, board.id, :update_searchable
        board.save
      end
    end
    
    context 'when not changing read permissions' do
      it 'should not modify searchable children' do
        board.permissions['write'] = 'admin'
        expect(BoardVisibilityWorker).to_not receive :perform_in
        board.save
      end
    end
  end
end
