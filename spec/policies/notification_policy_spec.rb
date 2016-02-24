require 'spec_helper'

RSpec.describe NotificationPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :notification }
  subject{ NotificationPolicy.new user, record }

  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end

  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end

  context 'with the owner' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :update
    it_behaves_like 'a policy forbidding', :create, :destroy
  end

  context 'with scope' do
    let!(:other_records){ create_list :notification, 2 }
    let(:user){ create :user }
    let(:records){ create_list :notification, 2, user: user }
    subject{ NotificationPolicy::Scope.new(user, Notification).resolve }

    it{ is_expected.to match_array records }
  end
end
