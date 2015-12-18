require 'spec_helper'

RSpec.describe DataRequestPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :data_request, section: 'project-1' }
  subject{ DataRequestPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :moderator }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end
  
  context 'with a non-section admin' do
    let(:user){ create :admin, section: 'project-2' }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'with a section admin' do
    let(:user){ create :admin, section: 'project-1' }
    it_behaves_like 'a policy permitting', :index, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with an owner admin' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with a zooniverse admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with scope' do
    let!(:user){ }
    let(:user_records){ create_list :data_request, 1, section: 'project-1', user: user }
    let!(:section_records){ create_list :data_request, 2, section: 'project-1' }
    let!(:other_records){ create_list :data_request, 2, section: 'project-2' }
    subject{ DataRequestPolicy::Scope.new(user, DataRequest).resolve }
    
    context 'with an owner admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array user_records }
    end
    
    context 'with a non-owner admin' do
      let(:user){ create :admin, section: 'project-1' }
      it{ is_expected.to match_array [] }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array user_records + section_records + other_records }
    end
  end
end
