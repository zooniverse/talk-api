require 'spec_helper'

RSpec.describe AnnouncementPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :announcement }
  let(:subject){ AnnouncementPolicy.new user, record }
  
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
    let(:user){ create :moderator, section: record.section }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :admin, section: record.section }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
end
