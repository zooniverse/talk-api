require 'spec_helper'

RSpec.describe Comment, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a body' do
      without_body = build :comment, body: nil
      expect(without_body).to fail_validation body: "can't be blank"
    end
    
    it 'should require a user' do
      without_user = build :comment, user_id: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a section' do
      without_section = build :comment, section: nil
      allow(without_section).to receive :set_section
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
  
  context 'creating' do
    it 'should set default attributes' do
      comment = create :comment
      expect(comment.tags).to eq({ })
      expect(comment.is_deleted).to be false
    end
    
    it 'should set the section' do
      comment = build :comment, section: nil
      expect{
        comment.validate
      }.to change{
        comment.section
      }.to comment.discussion.section
    end
    
    it 'should denormalize the user login' do
      comment = create :comment
      expect(comment.user_login).to eq comment.user.login
    end
    
    it 'should denormalize the focus type for focus subclasses' do
      subject_comment = create :comment, focus: build(:subject)
      expect(subject_comment.focus_type).to eql 'Subject'
    end
    
    it 'should not denormalize the focus type for the focus base class' do
      focus_comment = create :comment, focus: build(:focus)
      expect(focus_comment.focus_type).to be_nil
    end
    
    it 'should update the discussion comment count' do
      discussion = create :discussion
      expect {
        create :comment, discussion: discussion
      }.to change {
        discussion.reload.comments_count
      }.by 1
    end
    
    it 'should update the discussion updated_at timestamp' do
      discussion = create :discussion
      expect {
        create :comment, discussion: discussion
      }.to change {
        discussion.reload.updated_at
      }
    end
    
    it 'should update the focus comment count' do
      focus = create :focus
      expect {
        create :comment_for_focus, focus: focus
      }.to change {
        focus.reload.comments_count
      }.by 1
    end
    
    it 'should update the discussion user count' do
      discussion = create :discussion
      expect {
        comment = create :comment, discussion: discussion
        create_list :comment, 2, discussion: discussion
        create :comment, discussion: discussion, user: comment.user
      }.to change {
        discussion.reload.users_count
      }.by 3
    end
    
    context 'updating board counts' do
      let(:board) do
        discussion1 = create :discussion_with_comments, comment_count: 3, user_count: 2
        board = discussion1.board
        discussion2 = create :discussion_with_comments, board: board, comment_count: 3, user_count: 2
        board
      end
      
      it 'should update the comment count' do
        expect(board.comments_count).to eql 6
      end
      
      it 'should update the user count' do
        expect(board.users_count).to eql 4
      end
    end
  end
end
