require 'spec_helper'

RSpec.describe Discussion, type: :model do
  it_behaves_like 'a sectioned model'
  it_behaves_like 'moderatable'
  it_behaves_like 'a subscribable model'
  it_behaves_like 'a searchable interface'
  it_behaves_like 'a searchable model' do
    let(:searchable_board){ create :board }
    let(:searchable){ create :discussion, board: searchable_board }
    
    let(:unsearchable_board){ create :board, permissions: { read: 'admin' } }
    let(:unsearchable){ create :discussion, board: unsearchable_board }
  end
  
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
  
  describe '#subject_default' do
    let(:board){ create :board }
    let(:subject){ create :subject }
    let!(:default_discussion){ create :discussion, title: subject.id, board: board, subject_default: true }
    
    it 'should not allow other default discussions for the subject on the board' do
      expect {
        create :discussion, title: subject.id, board: board, subject_default: true
      }.to raise_error ActiveRecord::RecordNotUnique
    end
    
    it 'should be scoped to the board' do
      expect {
        create :discussion, title: subject.id, subject_default: true
      }.to_not raise_error
    end
    
    it 'should be scoped to the title' do
      expect {
        create :discussion, board: board, title: create(:subject).id, subject_default: true
      }.to_not raise_error
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
    
    context 'updating discussion counts' do
      let(:user){ create :user }
      let(:discussion){ build :discussion, user: user }
      let!(:comment){ discussion.comments.build user: user, body: 'asdf' }
      before(:each){ discussion.save }
      subject{ discussion }
      
      its(:comments_count){ is_expected.to eql 1 }
      its(:users_count){ is_expected.to eql 1 }
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
    it 'should destroy comments when all comments are marked as deleted' do
      discussion = create :discussion_with_comments, comment_count: 2
      discussion.destroy!
      expect(discussion.comments.count).to eql 0
    end
  end
  
  describe '#latest_comment' do
    let(:discussion){ create :discussion }
    let!(:older){ create :comment, discussion: discussion, created_at: 3.hours.ago.utc }
    let!(:newer){ create :comment, discussion: discussion, created_at: 2.hours.ago.utc }
    
    it 'should find the newest comment' do
      expect(discussion.latest_comment).to eql newer
    end
  end
  
  describe '#clear_sticky' do
    let(:discussion){ create :discussion, sticky: true, sticky_position: 1 }
    
    it 'should clear sticky' do
      expect{
        discussion.update_attributes sticky: false
      }.to change{
        discussion.sticky_position
      }.to nil
    end
  end
  
  describe '#set_sticky_position' do
    let(:board){ create :board }
    def create_discussion(position: nil)
      create :discussion, board: board, sticky: true, sticky_position: position
    end
    
    it 'should start with sticky_position 1' do
      expect(create_discussion.sticky_position).to eql 1.0
    end
    
    it 'should default to the next position' do
      create_discussion
      expect(create_discussion.sticky_position).to eql 2.0
    end
    
    it 'should not override the attribute' do
      create_discussion
      expect(create_discussion(position: 100).sticky_position).to eql 100.0
    end
  end
end
