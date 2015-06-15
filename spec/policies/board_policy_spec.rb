require 'spec_helper'

RSpec.describe BoardPolicy, type: :policy do
  let(:user){ }
  let(:subject){ BoardPolicy.new user, record }
  
  context 'with permissions read:all write:all' do
    let(:record){ create :board, section: 'project-1', permissions: { read: 'all', write: 'all' } }
    
    context 'without a user' do
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
    end
    
    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy
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
    let(:record){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    
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
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    end
  end
  
  context 'with permissions read:moderator write:moderator' do
    let(:record){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    
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
    let(:record){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    
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
      it_behaves_like 'a policy permitting', :create
      it_behaves_like 'a policy forbidding', :show, :update, :destroy
    end
    
    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy permitting', :show, :create, :update, :destroy
    end
  end
  
  context 'with scope' do
    let!(:public_boards){ create_list :board, 2, section: 'project-1' }
    let!(:team_boards){ create_list :board, 2, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    let!(:admin_boards){ create_list :board, 2, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    let!(:moderator_boards){ create_list :board, 2, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let!(:other_boards){ create_list :board, 2, section: 'project-2', permissions: { read: 'admin', write: 'admin' } }
    let(:subject){ BoardPolicy::Scope.new(user, Board).resolve }
    
    context 'without a user' do
      it{ is_expected.to match_array public_boards }
    end
    
    context 'with a scientist' do
      let(:user){ create :scientist, section: 'project-1' }
      it{ is_expected.to match_array public_boards + team_boards }
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator, section: 'project-1' }
      it{ is_expected.to match_array public_boards + team_boards + moderator_boards }
    end
    
    context 'with an admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array public_boards + team_boards + moderator_boards + admin_boards }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array public_boards + team_boards + moderator_boards + admin_boards + other_boards }
    end
  end
  
  context 'with mixed permissions' do
    let(:user){ create :moderator, section: 'project-1' }
    let(:permitted_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:unpermitted_board){ create :board, section: 'project-2', permissions: { read: 'moderator', write: 'moderator' } }
    let(:record){ [permitted_board, unpermitted_board] }
    
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
end
