require 'spec_helper'

RSpec.describe UserIpBanPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :user_ip_ban }
  subject{ UserIpBanPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a project admin' do
    let(:user){ create :admin, section: 'project-1' }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a zooniverse admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create, :destroy
    it_behaves_like 'a policy forbidding', :update
  end
end
