require 'spec_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  let(:user){ }
  let(:record){ OpenStruct.new }
  let(:subject){ ApplicationPolicy.new user, record }
  
  describe 'default actions' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'without a user' do
    it{ is_expected.to_not be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to_not be_team }
    it{ is_expected.to have_attributes user_roles: [] }
  end
  
  context 'with a user' do
    let(:user){ create :user }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-1' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to_not be_team }
    it{ is_expected.to have_attributes user_roles: [] }
  end
  
  context 'with a owner' do
    let(:user){ create :user }
    let(:record){ OpenStruct.new user_id: user.id, section: 'project-1' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to_not be_team }
    it{ is_expected.to have_attributes user_roles: [] }
  end
  
  context 'with a section moderator' do
    let(:user){ create :moderator, section: 'project-1' }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-1' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to be_team }
    it{ is_expected.to have_attributes user_roles: ['moderator'] }
  end
  
  context 'with a non-section moderator' do
    let(:user){ create :moderator, section: 'project-1' }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-2' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to_not be_team }
    it{ is_expected.to have_attributes user_roles: [] }
  end
  
  context 'with a zooniverse moderator' do
    let(:user){ create :moderator, section: 'zooniverse' }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-2' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to be_team }
    it{ is_expected.to have_attributes user_roles: ['moderator'] }
  end
  
  context 'with a section admin' do
    let(:user){ create :admin, section: 'project-1' }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-1' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to be_admin }
    it{ is_expected.to be_team }
    it{ is_expected.to have_attributes user_roles: ['admin'] }
  end
  
  context 'with a non-section admin' do
    let(:user){ create :admin, section: 'project-1' }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-2' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to_not be_team }
    it{ is_expected.to have_attributes user_roles: [] }
  end
  
  context 'with a zooniverse admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    let(:record){ OpenStruct.new user_id: user.id + 1, section: 'project-2' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to be_admin }
    it{ is_expected.to be_team }
    it{ is_expected.to have_attributes user_roles: ['admin'] }
  end
end
