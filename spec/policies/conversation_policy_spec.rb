require 'spec_helper'

RSpec.describe ConversationPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :conversation_with_messages }
  subject{ ConversationPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :create
    it_behaves_like 'a policy forbidding', :show, :update, :destroy
  end
  
  context 'with a participant' do
    let(:user){ record.users.first }
    it_behaves_like 'a policy permitting', :index, :show, :create, :destroy
    it_behaves_like 'a policy forbidding', :update
  end
  
  context 'with a moderator' do
    let(:user){ create :moderator, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :conversation_with_messages, 2 }
    let(:user){ create :user }
    let(:records){ create_list :conversation_with_messages, 2, user: user }
    subject{ ConversationPolicy::Scope.new(user, Conversation).resolve }
    
    it{ is_expected.to match_array records }
  end
end
