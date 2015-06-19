require 'spec_helper'

RSpec.describe Discussion, type: :model do
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
end
