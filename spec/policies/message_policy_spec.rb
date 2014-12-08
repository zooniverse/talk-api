require 'spec_helper'

RSpec.describe MessagePolicy, type: :policy do
  let(:user){ }
  let(:record){ create :message }
  let(:subject){ MessagePolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end
  
  context 'with a participant' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    it_behaves_like 'a policy permitting', :show
    it_behaves_like 'a policy forbidding', :index, :create, :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :user, roles: { zooniverse: ['admin'] } }
    it_behaves_like 'a policy permitting', :show
    it_behaves_like 'a policy forbidding', :index, :create, :update, :destroy
  end
  
  context 'with scope' do
    let!(:other_records){ create_list :message, 2 }
    let(:message){ create :message }
    let(:record){ create :message, conversation: message.conversation }
    let(:user){ record.user }
    let(:subject){ MessagePolicy::Scope.new(user, Message).resolve }
    
    it{ is_expected.to match_array [record, message] }
  end
end
