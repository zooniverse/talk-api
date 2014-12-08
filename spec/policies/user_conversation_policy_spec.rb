require 'spec_helper'

RSpec.describe UserConversationPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :user_conversation }
  let(:subject){ UserConversationPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :create
    it_behaves_like 'a policy forbidding', :index, :show, :update, :destroy
  end
  
  context 'with the owner' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    it_behaves_like 'a policy permitting', :show, :create
    it_behaves_like 'a policy forbidding', :index, :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :user, roles: { zooniverse: ['admin'] } }
    it_behaves_like 'a policy permitting', :show, :create
    it_behaves_like 'a policy forbidding', :index, :update, :destroy
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :user_conversation, 2 }
    let(:user){ create :user }
    let(:records){ create_list :user_conversation, 2, user: user }
    let(:subject){ UserConversationPolicy::Scope.new(user, UserConversation).resolve }
    
    it{ is_expected.to match_array records }
  end
end
