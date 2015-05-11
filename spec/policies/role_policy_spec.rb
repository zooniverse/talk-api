require 'spec_helper'

RSpec.describe RolePolicy, type: :policy do
  let(:user){ }
  let(:role_user){ create :user }
  let(:record){ build :moderator_role, user: role_user }
  let(:subject){ RolePolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :moderator }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a non-section admin' do
    let(:user){ create :admin, section: 'other' }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a section admin' do
    let(:user){ create :admin, section: 'test' }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with a zooniverse admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with scope' do
    let!(:section_roles){ create_list :role, 2, section: '1-project' }
    let!(:other_roles){ create_list :role, 2, section: '2-project' }
    let!(:zooniverse_roles){ create_list :role, 2, section: 'zooniverse' }
    let(:user_roles){ user ? user.roles.to_a : [] }
    let(:subject){ RolePolicy::Scope.new(user, Role).resolve }
    
    context 'without a user' do
      it{ is_expected.to be_empty }
    end
    
    context 'with a scientist' do
      let(:user){ create :scientist, section: '1-project' }
      it{ is_expected.to be_empty }
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator, section: '1-project' }
      it{ is_expected.to be_empty }
    end
    
    context 'with a section admin' do
      let(:user){ create :admin, section: '1-project' }
      it{ is_expected.to match_array section_roles + user_roles }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array section_roles + other_roles + zooniverse_roles + user_roles }
    end
  end
end
