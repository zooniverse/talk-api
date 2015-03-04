require 'spec_helper'

RSpec.describe CommentPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :comment, section: 'test' }
  let(:subject){ CommentPolicy.new user, record }
  
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
end
