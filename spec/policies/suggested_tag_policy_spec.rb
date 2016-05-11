require 'spec_helper'

RSpec.describe SuggestedTagPolicy, type: :policy do
  let(:user){ }
  let(:suggested_tag_user){ create :user }
  let(:record){ build :suggested_tag }
  subject{ SuggestedTagPolicy.new user, record }

  context 'without a user' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with a non-section admin' do
    let(:user){ create :admin, section: 'project-2' }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with a section moderator' do
    let(:user){ create :moderator }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end

  context 'with a section admin' do
    let(:user){ create :admin, section: 'project-1' }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end

  context 'with a zooniverse admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
end
