require 'spec_helper'

RSpec.describe Discussion, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a title' do
      without_title = build :discussion, title: nil
      expect(without_title).to_not be_valid
      expect(without_title).to fail_validation title: "can't be blank"
    end
    
    it 'should limit title length' do
      short_title = build :discussion, title: 'a'
      expect(short_title).to fail_validation title: 'too short'
      long_title = build :discussion, title: '!' * 200
      expect(long_title).to fail_validation title: 'too long'
    end
    
    it 'should require a user' do
      without_user = build :discussion, user_id: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a section' do
      without_section = build :discussion, section: nil
      allow(without_section).to receive :set_section
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
  
  context 'creating' do
    it 'should set the section' do
      discussion = build :discussion, section: nil
      expect{
        discussion.validate
      }.to change{
        discussion.section
      }.to discussion.board.section
    end
    
    it 'should denormalize the user login' do
      discussion = create :discussion
      expect(discussion.user_login).to eq discussion.user.login
    end
    
    it 'should update the board discussion count' do
      board = create :board_with_discussions, discussion_count: 2
      expect {
        create :discussion, board: board
      }.to change {
        board.reload.discussions_count
      }.by 1
    end
  end
  
  context 'updating' do
    let!(:source){ create :board }
    let!(:destination){ create :board }
    let!(:discussion){ create :discussion, board: source }
    let!(:comment){ create :comment, discussion: discussion }
    
    def move_discussion
      Discussion.find(discussion.id).update! board_id: destination.id
    end
    
    it 'should update the source discussions_count' do
      expect{ move_discussion }.to change{ source.reload.discussions_count }.from(1).to 0
    end
    
    it 'should update the source comments_count' do
      expect{ move_discussion }.to change{ source.reload.comments_count }.from(1).to 0
    end
    
    it 'should update the source users_count' do
      expect{ move_discussion }.to change{ source.reload.users_count }.from(1).to 0
    end
    
    it 'should update the destination discussions_count' do
      expect{ move_discussion }.to change{ destination.reload.discussions_count }.from(0).to 1
    end
    
    it 'should update the destination comments_count' do
      expect{ move_discussion }.to change{ destination.reload.comments_count }.from(0).to 1
    end
    
    it 'should update the destination users_count' do
      expect{ move_discussion }.to change{ destination.reload.users_count }.from(0).to 1
    end
  end
  
  context 'destroying' do
    it 'should not be destroyable when comments exist' do
      discussion = create :discussion_with_comments, comment_count: 2
      expect{ discussion.destroy! }.to raise_exception ActiveRecord::RecordNotDestroyed
    end
    
    it 'should report an error when comments exist' do
      discussion = create :discussion_with_comments, comment_count: 2
      discussion.destroy
      message = discussion.errors.messages[:comments].try(:first) || ''
      expect(message).to include 'dependent comments exist'
    end
    
    it 'should not destroy comments unless all comments are marked as deleted' do
      discussion = create :discussion_with_comments, comment_count: 2
      discussion.comments.first.update_attribute 'is_deleted', true
      discussion.destroy
      expect(discussion.comments.count).to eql 2
    end
    
    it 'should be destroyable when no comments exist' do
      discussion = create :discussion
      expect{ discussion.destroy! }.to_not raise_exception
    end
    
    it 'should be destroyable when all comments are marked as deleted' do
      discussion = create :discussion_with_comments, comment_count: 2
      discussion.comments.update_all is_deleted: true
      expect{ discussion.destroy! }.to_not raise_exception
    end
    
    it 'should destroy comments when all comments are marked as deleted' do
      discussion = create :discussion_with_comments, comment_count: 2
      discussion.comments.update_all is_deleted: true
      discussion.destroy!
      expect(discussion.comments.count).to eql 0
    end
  end
end
