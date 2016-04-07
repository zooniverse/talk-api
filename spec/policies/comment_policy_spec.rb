require 'spec_helper'

RSpec.describe CommentPolicy, type: :policy do
  let(:user){ }
  let(:board){ create :board }
  let(:discussion){ create :discussion, board: board }
  let(:record){ create :comment, discussion: discussion }
  subject{ CommentPolicy.new user, record }

  context 'with permissions read:all write:all' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'all', write: 'all' } }

    context 'without a user' do
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy permitting', :index, :show, :create, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy, :move
    end

    context 'with the owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy, :move
      it_behaves_like 'a policy forbidding', :upvote, :remove_upvote
    end

    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end

    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end
  end

  context 'with permissions read:team write:team' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }

    context 'without a user' do
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a team member' do
      let(:user){ create :scientist }
      it_behaves_like 'a policy permitting', :index, :show, :create
      it_behaves_like 'a policy forbidding', :update, :destroy
    end

    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end

    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end
  end

  context 'with permissions read:moderator write:moderator' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }

    context 'without a user' do
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a team member' do
      let(:user){ create :scientist }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with the owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end

    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end
  end

  context 'with permissions read:admin write:admin' do
    let(:board){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }

    context 'without a user' do
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a user' do
      let(:user){ create :user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a team member' do
      let(:user){ create :scientist }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with the owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with a moderator' do
      let(:user){ create :moderator }
      it_behaves_like 'a policy excluding'
      it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy, :move, :upvote, :remove_upvote
    end

    context 'with an admin' do
      let(:user){ create :admin }
      it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote, :remove_upvote
      it_behaves_like 'a policy forbidding', :update, :destroy
    end
  end

  context 'with a locked discussion' do
    let(:user){ create :user }
    before(:each){ record.discussion.update_attributes locked: true }
    it_behaves_like 'a policy permitting', :index, :show, :upvote, :remove_upvote
    it_behaves_like 'a policy forbidding', :create, :update, :destroy, :move

    context 'with the comment owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :create, :update, :destroy, :move, :upvote, :remove_upvote
    end
  end

  context 'with a deleted comment' do
    let(:record){ create :comment, discussion: discussion, is_deleted: true }
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :update, :destroy, :upvote, :remove_upvote

    context 'with the comment owner' do
      let(:user){ record.user }
      it_behaves_like 'a policy permitting', :index, :show
      it_behaves_like 'a policy forbidding', :update, :destroy, :move, :upvote, :remove_upvote
    end
  end

  context 'with scope' do
    let(:public_board){ create :board, section: 'project-1' }
    let(:public_discussion){ create :discussion, board: public_board }
    let!(:public_comments){ create_list :comment, 2, discussion: public_discussion }

    let(:team_board){ create :board, section: 'project-1', permissions: { read: 'team', write: 'team' } }
    let(:team_discussion){ create :discussion, board: team_board }
    let(:team_comments){ create_list :comment, 2, discussion: team_discussion }

    let(:admin_board){ create :board, section: 'project-1', permissions: { read: 'admin', write: 'admin' } }
    let(:admin_discussion){ create :discussion, board: admin_board }
    let(:admin_comments){ create_list :comment, 2, discussion: admin_discussion }

    let(:moderator_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:moderator_discussion){ create :discussion, board: moderator_board }
    let(:moderator_comments){ create_list :comment, 2, discussion: moderator_discussion }

    let(:other_board){ create :board, section: 'project-2', permissions: { read: 'admin', write: 'admin' } }
    let(:other_discussion){ create :discussion, board: other_board }
    let(:other_comments){ create_list :comment, 2, discussion: other_discussion }

    subject{ CommentPolicy::Scope.new(user, Comment).resolve }

    context 'without a user' do
      it{ is_expected.to match_array public_comments }
    end

    context 'with a scientist' do
      let(:user){ create :scientist, section: 'project-1' }
      it{ is_expected.to match_array public_comments + team_comments }
    end

    context 'with a moderator' do
      let(:user){ create :moderator, section: 'project-1' }
      it{ is_expected.to match_array public_comments + team_comments + moderator_comments }
    end

    context 'with an admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array public_comments + team_comments + moderator_comments + admin_comments }
    end

    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array public_comments + team_comments + moderator_comments + admin_comments + other_comments }
    end
  end

  context 'with mixed permissions' do
    let(:user){ create :moderator, section: 'project-1' }

    let(:permitted_board){ create :board, section: 'project-1', permissions: { read: 'moderator', write: 'moderator' } }
    let(:permitted_discussion){ create :discussion, board: permitted_board }
    let(:permitted_comment){ create :comment, discussion: permitted_discussion }

    let(:unpermitted_board){ create :board, section: 'project-2', permissions: { read: 'moderator', write: 'moderator' } }
    let(:unpermitted_discussion){ create :discussion, board: unpermitted_board }
    let(:unpermitted_comment){ create :comment, discussion: unpermitted_discussion }

    let(:record){ [permitted_comment, unpermitted_comment] }

    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
end
