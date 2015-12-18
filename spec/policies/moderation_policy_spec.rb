require 'spec_helper'

RSpec.describe ModerationPolicy, type: :policy do
  let(:user){ }
  let(:comment){ create :comment, section: 'project-1' }
  let(:record){ create :moderation, target: comment }
  subject{ ModerationPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
    its(:available_actions){ is_expected.to be_empty }
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :create
    it_behaves_like 'a policy forbidding', :show, :update, :destroy
    its(:available_actions){ is_expected.to match_array [:report] }
  end
  
  context 'with a moderator' do
    let(:user){ create :moderator, section: record.section }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    its(:available_actions){ is_expected.to match_array [:report, :destroy, :ignore] }
  end
  
  context 'with an admin' do
    let(:user){ create :admin, section: record.section }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
    its(:available_actions){ is_expected.to match_array [:report, :destroy, :ignore] }
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :moderation, 2, section: 'project-2' }
    let(:user){ create :moderator, section: 'project-1' }
    let(:records){ create_list :moderation, 2, section: 'project-1' }
    subject{ ModerationPolicy::Scope.new(user, Moderation).resolve }
    
    it{ is_expected.to match_array records }
  end
end
