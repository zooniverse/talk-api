require 'spec_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  let(:user){ }
  let(:record){ OpenStruct.new }
  let(:subject){ ApplicationPolicy.new user, record }
  
  describe 'default actions' do
    it{ is_expected.to permit :index }
    it{ is_expected.to permit :show }
    it{ is_expected.to_not permit :create }
    it{ is_expected.to_not permit :update }
    it{ is_expected.to_not permit :destroy }
  end
  
  context 'without a user' do
    it{ is_expected.to_not be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: [] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a user' do
    let(:user){ OpenStruct.new id: 1, roles: { } }
    let(:record){ OpenStruct.new user_id: 2, section: 'a' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: [] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a owner' do
    let(:user){ OpenStruct.new id: 1, roles: { } }
    let(:record){ OpenStruct.new user_id: 1, section: 'a' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: [] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a section moderator' do
    let(:user){ OpenStruct.new id: 1, roles: { 'a' => ['moderator'] } }
    let(:record){ OpenStruct.new user_id: 2, section: 'a' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: ['moderator'] }
    it{ is_expected.to have_attributes section_roles: ['moderator'] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a non-section moderator' do
    let(:user){ OpenStruct.new id: 1, roles: { 'a' => ['moderator'] } }
    let(:record){ OpenStruct.new user_id: 2, section: 'b' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: [] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a zooniverse moderator' do
    let(:user){ OpenStruct.new id: 1, roles: { 'zooniverse' => ['moderator'] } }
    let(:record){ OpenStruct.new user_id: 2, section: 'b' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: ['moderator'] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: ['moderator'] }
  end
  
  context 'with a section admin' do
    let(:user){ OpenStruct.new id: 1, roles: { 'a' => ['admin'] } }
    let(:record){ OpenStruct.new user_id: 2, section: 'a' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to be_admin }
    it{ is_expected.to have_attributes user_roles: ['admin'] }
    it{ is_expected.to have_attributes section_roles: ['admin'] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a non-section admin' do
    let(:user){ OpenStruct.new id: 1, roles: { 'a' => ['admin'] } }
    let(:record){ OpenStruct.new user_id: 2, section: 'b' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to_not be_admin }
    it{ is_expected.to have_attributes user_roles: [] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: [] }
  end
  
  context 'with a zooniverse admin' do
    let(:user){ OpenStruct.new id: 1, roles: { 'zooniverse' => ['admin'] } }
    let(:record){ OpenStruct.new user_id: 2, section: 'b' }
    
    it{ is_expected.to be_logged_in }
    it{ is_expected.to_not be_owner }
    it{ is_expected.to_not be_moderator }
    it{ is_expected.to be_admin }
    it{ is_expected.to have_attributes user_roles: ['admin'] }
    it{ is_expected.to have_attributes section_roles: [] }
    it{ is_expected.to have_attributes zooniverse_roles: ['admin'] }
  end
end
