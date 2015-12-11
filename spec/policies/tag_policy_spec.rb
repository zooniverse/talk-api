require 'spec_helper'

RSpec.describe TagPolicy, type: :policy do
  let(:user){ }
  let(:board){ create :board }
  let(:discussion){ create :discussion, board: board }
  let(:comment){ create :comment, discussion: discussion, body: 'testing #test' }
  let(:record){ comment.tags.first }
  subject{ TagPolicy.new user, record }
  
  context 'with permissions read:all write:all' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'all', write: 'all' } }
    
    context 'without a user' do
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with the owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
  end
  
  context 'with permissions read:team write:team' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    
    context 'without a user' do
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a team member' do
      let(:user){ create :scientist }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
  end
  
  context 'with permissions read:moderator write:moderator' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    
    context 'without a user' do
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a team member' do
      let(:user){ create :scientist }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with the owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
  end
  
  context 'with permissions read:admin write:admin' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    
    context 'without a user' do
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a team member' do
      let(:user){ create :scientist }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with the owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
  end
  
  context 'with scope' do
    let(:public_board){ create :board, section: 'project-1' }
    let(:public_discussion){ create :discussion, board: public_board }
    let!(:public_comments){ create_list :comment, 2, discussion: public_discussion, body: '#test1' }
    let(:public_tags){ public_comments.collect(&:tags).flatten }
    
    let(:team_board){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    let(:team_discussion){ create :discussion, board: team_board }
    let(:team_comments){ create_list :comment, 2, discussion: team_discussion, body: '#test2' }
    let(:team_tags){ team_comments.collect(&:tags).flatten }
    
    let(:admin_board){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    let(:admin_discussion){ create :discussion, board: admin_board }
    let(:admin_comments){ create_list :comment, 2, discussion: admin_discussion, body: '#test3' }
    let(:admin_tags){ admin_comments.collect(&:tags).flatten }
    
    let(:moderator_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:moderator_discussion){ create :discussion, board: moderator_board }
    let(:moderator_comments){ create_list :comment, 2, discussion: moderator_discussion, body: '#test4' }
    let(:moderator_tags){ moderator_comments.collect(&:tags).flatten }
    
    let(:other_board){ create :board, section: 'project-2', permissions: { read: 'admin', write: 'admin' } }
    let(:other_discussion){ create :discussion, board: other_board }
    let(:other_comments){ create_list :comment, 2, discussion: other_discussion, body: '#test5' }
    let(:other_tags){ other_comments.collect(&:tags).flatten }
    
    subject{ TagPolicy::Scope.new(user, Tag).resolve }
    
    context 'without a user' do
      it{ is_expected.to match_array public_tags }
    end
    
    context 'with a scientist' do
      let(:user){ create :scientist, section: 'project-1' }
      it{ is_expected.to match_array public_tags + team_tags }
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator, section: 'project-1' }
      it{ is_expected.to match_array public_tags + team_tags + moderator_tags }
    end
    
    context 'with an admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array public_tags + team_tags + moderator_tags + admin_tags }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array public_tags + team_tags + moderator_tags + admin_tags + other_tags }
    end
  end
  
  context 'with mixed permissions' do
    let(:user){ create :moderator, section: 'project-1' }
    
    let(:permitted_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:permitted_discussion){ create :discussion, board: permitted_board }
    let(:permitted_comment){ create :comment, discussion: permitted_discussion, body: '#test1' }
    
    let(:unpermitted_board){ create :board, section: 'project-2', permissions: { read: 'moderator', write: 'moderator' } }
    let(:unpermitted_discussion){ create :discussion, board: unpermitted_board }
    let(:unpermitted_comment){ create :comment, discussion: unpermitted_discussion, body: '#test2' }
    
    let(:record){ [permitted_comment.tags.first, unpermitted_comment.tags.first] }
    
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
end
