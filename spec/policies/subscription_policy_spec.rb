require 'spec_helper'

RSpec.describe SubscriptionPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :subscription }
  let(:subject){ SubscriptionPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
  
  context 'with the owner' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :update
    it_behaves_like 'a policy forbidding', :create, :destroy
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :subscription, 2 }
    let(:user){ create :user }
    let(:records){ create_list :subscription, 2, user: user }
    let(:subject){ SubscriptionPolicy::Scope.new(user, Subscription).resolve }
    
    it{ is_expected.to match_array records }
  end
end
