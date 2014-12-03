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
  end
  
  context 'creating' do
    it 'should denormalize the user name' do
      discussion = create :discussion
      expect(discussion.user_name).to eq discussion.user.name
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
