require 'spec_helper'

RSpec.describe MentionPolicy, type: :policy do
  let(:user){ }
  let(:board){ create :board }
  let(:discussion){ create :discussion, board: board }
  let(:comment){ create :comment, discussion: discussion }
  let(:record){ create :mention, comment: comment }
  subject{ MentionPolicy.new user, record }
  
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
    let(:public_comment){ create :comment, discussion: discussion }
    let!(:public_mentions){ create_list :mention, 2, comment: public_comment }
    
    let(:team_board){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    let(:team_discussion){ create :discussion, board: team_board }
    let(:team_comment){ create :comment, discussion: team_discussion }
    let(:team_mentions){ create_list :mention, 2, comment: team_comment }
    
    let(:admin_board){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    let(:admin_discussion){ create :discussion, board: admin_board }
    let(:admin_comment){ create :comment, discussion: admin_discussion }
    let(:admin_mentions){ create_list :mention, 2, comment: admin_comment }
    
    let(:moderator_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:moderator_discussion){ create :discussion, board: moderator_board }
    let(:moderator_comment){ create :comment, discussion: moderator_discussion }
    let(:moderator_mentions){ create_list :mention, 2, comment: moderator_comment }
    
    let(:other_board){ create :board, section: 'project-2', permissions: { read: 'admin', write: 'admin' } }
    let(:other_discussion){ create :discussion, board: other_board }
    let(:other_comment){ create :comment, discussion: other_discussion }
    let(:other_mentions){ create_list :mention, 2, comment: other_comment }
    
    subject{ MentionPolicy::Scope.new(user, Mention).resolve }
    
    context 'without a user' do
      it{ is_expected.to match_array public_mentions }
    end
    
    context 'with a scientist' do
      let(:user){ create :scientist, section: 'project-1' }
      it{ is_expected.to match_array public_mentions + team_mentions }
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator, section: 'project-1' }
      it{ is_expected.to match_array public_mentions + team_mentions + moderator_mentions }
    end
    
    context 'with an admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array public_mentions + team_mentions + moderator_mentions + admin_mentions }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array public_mentions + team_mentions + moderator_mentions + admin_mentions + other_mentions }
    end
  end
  
  context 'with mixed permissions' do
    let(:user){ create :moderator, section: 'project-1' }
    
    let(:permitted_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:permitted_discussion){ create :discussion, board: permitted_board }
    let(:permitted_comment){ create :comment, discussion: permitted_discussion }
    let(:permitted_mention){ create :mention, comment: permitted_comment }
    
    let(:unpermitted_board){ create :board, section: 'project-2', permissions: { read: 'moderator', write: 'moderator' } }
    let(:unpermitted_discussion){ create :discussion, board: unpermitted_board }
    let(:unpermitted_comment){ create :comment, discussion: unpermitted_discussion }
    let(:unpermitted_mention){ create :mention, comment: unpermitted_comment }
    
    let(:record){ [permitted_mention, unpermitted_mention] }
    
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
end
