require 'spec_helper'

RSpec.describe CommentPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :comment, section: 'test' }
  let(:subject){ CommentPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy, :move, :upvote
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :show, :create, :upvote
    it_behaves_like 'a policy forbidding', :update, :destroy, :move
  end
  
  context 'with the owner' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy, :move
    it_behaves_like 'a policy forbidding', :upvote
  end
  
  context 'with a moderator' do
    let(:user){ create :user, roles: { test: ['moderator'] } }
    it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :user, roles: { test: ['admin'] } }
    it_behaves_like 'a policy permitting', :index, :show, :create, :move, :upvote
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
end
