require 'spec_helper'

RSpec.describe CollectionPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :collection }
  let(:subject){ CollectionPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with the owner' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :user, roles: { test: ['moderator'] } }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :user, roles: { test: ['admin'] } }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
end
