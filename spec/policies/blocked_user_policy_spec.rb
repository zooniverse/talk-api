require 'spec_helper'

RSpec.describe BlockedUserPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :blocked_user }
  subject{ BlockedUserPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'without an authorized user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :create
    it_behaves_like 'a policy forbidding', :show, :update, :destroy
  end
  
  context 'with the owner' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create, :destroy
    it_behaves_like 'a policy forbidding', :update
  end
  
  context 'with a project admin' do
    let(:user){ create :admin, section: 'something-else' }
    it_behaves_like 'a policy permitting', :index, :create
    it_behaves_like 'a policy forbidding', :show, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :moderator, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :blocked_user, 2 }
    let(:user){ create :user }
    let(:records){ create_list :blocked_user, 2, user: user }
    subject{ BlockedUserPolicy::Scope.new(user, BlockedUser).resolve }
    
    it{ is_expected.to match_array records }
  end
end
