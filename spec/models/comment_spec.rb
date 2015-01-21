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
      expect(comment.tagging).to eql({ })
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
    
    context 'destroying' do
      let(:subject){ create :subject }
      let(:comment){ create :comment, body: "#tag, ^S#{ subject.id }" }
      
      it 'should destroy tags' do
        tag = comment.tags.first
        comment.destroy
        expect{ tag.reload }.to raise_error ActiveRecord::RecordNotFound
      end
      
      it 'should destroy mentions' do
        mention = comment.mentions.first
        comment.destroy
        expect{ mention.reload }.to raise_error ActiveRecord::RecordNotFound
      end
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
  
  context 'when moving discussions' do
    let!(:source){ create :discussion }
    let!(:destination){ create :discussion }
    let!(:comment){ create :comment, discussion: source }
    
    def move_comment
      Comment.find(comment.id).update! discussion_id: destination.id
    end
    
    it 'should update the source users_count' do
      expect{ move_comment }.to change{ source.reload.users_count }.by -1
    end
    
    it 'should update the source comments_count' do
      expect{ move_comment }.to change{ source.reload.comments_count }.from(1).to 0
    end
    
    it 'should update the source board comments_counts' do
      expect{ move_comment }.to change{ source.board.reload.comments_count }.from(1).to 0
    end
    
    it 'should update the source board users_counts' do
      expect{ move_comment }.to change{ source.board.reload.users_count }.from(1).to 0
    end
    
    it 'should update the destination users_count' do
      expect{ move_comment }.to change{ destination.reload.users_count }.from(0).to 1
    end
    
    it 'should update the destination comments_count' do
      expect{ move_comment }.to change{ destination.reload.comments_count }.from(0).to 1
    end
    
    it 'should update the destination board comments_counts' do
      expect{ move_comment }.to change{ destination.board.reload.comments_count }.from(0).to 1
    end
    
    it 'should update the destination board users_counts' do
      expect{ move_comment }.to change{ destination.board.reload.users_count }.from(0).to 1
    end
  end
  
  describe '#parse_mentions' do
    let(:subject){ create :subject }
    let(:subject_mention){ "^S#{ subject.id }" }
    
    let(:collection){ create :collection }
    let(:collection_mention){ "^C#{ collection.id }" }
    
    let(:user){ create :user }
    let(:user_mention){ "@#{ user.login }" }
    
    let(:body){ "#{ subject_mention } should be added to #{ collection_mention }, right @#{ user.login }?" }
    let(:comment){ create :comment, body: body }
    
    it 'should match subjects' do
      expect(comment.mentioning).to include subject_mention => {
        'id' => subject.id, 'type' => 'Subject'
      }
    end
    
    it 'should match collections' do
      expect(comment.mentioning).to include collection_mention => {
        'id' => collection.id, 'type' => 'Collection'
      }
    end
    
    it 'should match users' do
      expect(comment.mentioning).to include user_mention => {
        'id' => user.id, 'type' => 'User'
      }
    end
    
    it 'should create mentions for subjects' do
      expect(comment.mentions.where(mentionable: subject).exists?).to be true
    end
    
    it 'should create mentions for collections' do
      expect(comment.mentions.where(mentionable: collection).exists?).to be true
    end
    
    it 'should create mentions for users' do
      expect(comment.mentions.where(mentionable: user).exists?).to be true
    end
  end
  
  describe '#update_mentions' do
    let(:subject){ create :subject }
    let(:subject_mention){ "^S#{ subject.id }" }
    let(:collection){ create :collection }
    let(:collection_mention){ "^C#{ collection.id }" }
    let(:comment){ create :comment, body: "#{ subject_mention } #{ collection_mention }" }
    
    it 'should remove mentions on update' do
      comment.update! body: subject_mention
      expect(comment.mentions.where(mentionable: collection).exists?).to be false
    end
    
    it 'should add mentions on update' do
      subject2 = create :subject
      comment.update! body: "#{ comment.body } ^S#{ subject2.id }"
      expect(comment.mentions.where(mentionable: subject2).exists?).to be true
    end
  end
  
  describe '#parse_tags' do
    let(:comment){ create :comment, body: '#tag1 not#atag #Tag' }
    
    it 'should match tags' do
      expect(comment.tagging).to eql '#tag1' => 'tag1', '#Tag' => 'tag'
    end
    
    it 'should create tags' do
      expect(comment.tags.where(name: 'tag1').exists?).to be true
      expect(comment.tags.where(name: 'tag').exists?).to be true
      expect(comment.tags.count).to eql 2
    end
  end
end
