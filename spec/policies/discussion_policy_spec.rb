require 'spec_helper'

RSpec.describe DiscussionPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :discussion, board: board, section: 'project-1' }
  let(:subject){ DiscussionPolicy.new user, record }
  
  context 'with permissions read:all write:all' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'all', write: 'all' } }
    
    context 'without a user' do
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy permitting', :index, :show, :create
      it_behaves_like 'a policy forbidding', :update, :destroy
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
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
      it_behaves_like 'a policy permitting', :index, :show, :create
      it_behaves_like 'a policy forbidding', :update, :destroy
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
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
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
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
    
    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy permitting', :show, :create, :update, :destroy
    end
  end
  
  context 'with scope' do
    let(:public_board){ create :board, section: 'project-1' }
    let!(:public_discussions){ create_list :discussion, 2, board: public_board }
    
    let(:team_board){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    let!(:team_discussions){ create_list :discussion, 2, board: team_board }
    
    let(:admin_board){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    let!(:admin_discussions){ create_list :discussion, 2, board: admin_board }
    
    let(:moderator_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let!(:moderator_discussions){ create_list :discussion, 2, board: moderator_board }
    
    let(:other_board){ create :board, section: 'project-2', permissions: { read: 'admin', write: 'admin' } }
    let!(:other_discussions){ create_list :discussion, 2, board: other_board }
    
    let(:subject){ DiscussionPolicy::Scope.new(user, Discussion).resolve }
    
    context 'without a user' do
      it{ is_expected.to match_array public_discussions }
    end
    
    context 'with a scientist' do
      let(:user){ create :scientist, section: 'project-1' }
      it{ is_expected.to match_array public_discussions + team_discussions }
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator, section: 'project-1' }
      it{ is_expected.to match_array public_discussions + team_discussions + moderator_discussions }
    end
    
    context 'with an admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array public_discussions + team_discussions + moderator_discussions + admin_discussions }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array public_discussions + team_discussions + moderator_discussions + admin_discussions + other_discussions }
    end
  end
  
  context 'with mixed permissions' do
    let(:user){ create :moderator, section: 'project-1' }
    let(:permitted_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:permitted_discussion){ create :discussion, board: permitted_board }
    let(:unpermitted_board){ create :board, section: 'project-2', permissions: { read: 'moderator', write: 'moderator' } }
    let(:unpermitted_discussion){ create :discussion, board: unpermitted_board }
    let(:record){ [permitted_discussion, unpermitted_discussion] }
    
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
end
