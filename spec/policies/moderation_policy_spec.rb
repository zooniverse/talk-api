require 'spec_helper'

RSpec.describe ModerationPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :moderation, section: 'test' }
  let(:subject){ ModerationPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :create
    it_behaves_like 'a policy forbidding', :index, :show, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :user, roles: { test: ['moderator'] } }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :user, roles: { test: ['admin'] } }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :moderation, 2, section: 'other' }
    let(:user){ create :user, roles: { test: ['moderator'] } }
    let(:records){ create_list :moderation, 2, section: 'test' }
    let(:subject){ ModerationPolicy::Scope.new(user, Moderation).resolve }
    
    it{ is_expected.to match_array records }
  end
end
