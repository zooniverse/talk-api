require 'spec_helper'

RSpec.describe BoardPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :board, section: 'test' }
  let(:subject){ BoardPolicy.new user, record }
  
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
