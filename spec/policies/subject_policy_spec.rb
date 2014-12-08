require 'spec_helper'

RSpec.describe SubjectPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :subject }
  let(:subject){ SubjectPolicy.new user, record }
  
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
    let(:user){ create :user, roles: { test: ['moderator'] } }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :user, roles: { test: ['admin'] } }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
end
