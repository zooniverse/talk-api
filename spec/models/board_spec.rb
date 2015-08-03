require 'spec_helper'

RSpec.describe Board, type: :model do
  it_behaves_like 'a sectioned model'
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
    
    it 'should restrict deletion with dependent discussions' do
      board = create :board_with_discussions
      expect{ board.reload.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
      board.discussions.destroy_all
      expect{ board.destroy! }.to_not raise_error
    end
  end
  
  describe '#latest_discussion' do
    let(:board){ create :board }
    let!(:older){ create :discussion, board: board, created_at: 3.hours.ago.utc }
    let!(:newer){ create :discussion, board: board, created_at: 2.hours.ago.utc }
    
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
  
  describe '#cascade_searchable' do
    let(:board){ create :board_with_discussions, discussion_count: 2 }
    let(:children){ board.discussions.all.to_a + board.comments.all.to_a }
    let(:comments) do
      board.discussions.collect do |discussion|
        create_list :comment, discussion: discussion
      end.flatten
    end
    
    def expect_searchable(obj, exists:)
      expect(!!obj.searchable).to be exists
    end
    
    context 'when changing from public to private' do
      it 'should initially be searchable' do
        children.each do |child|
          expect_searchable child, exists: true
        end
      end
      
      it 'should remove all searchable children' do
        board.permissions['read'] = 'private'
        board.save
        children.each do |child|
          expect_searchable child, exists: false
        end
      end
    end
    
    context 'when changing from private to public' do
      let(:board){ create :board_with_discussions, discussion_count: 2, permissions: { read: 'admin' } }
      
      it 'should initially be unsearchable' do
        children.each do |child|
          expect_searchable child, exists: false
        end
      end
      
      it 'should remove all searchable children' do
        board.permissions['read'] = 'all'
        board.save
        children.each do |child|
          expect_searchable child, exists: true
        end
      end
    end
    
    context 'when not changing read permissions' do
      it 'should remove all searchable children' do
        board.permissions['write'] = 'admin'
        board.save
        children.each do |child|
          expect_searchable child, exists: true
        end
      end
    end
  end
end
