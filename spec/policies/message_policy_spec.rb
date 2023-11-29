require 'spec_helper'

RSpec.describe MessagePolicy, type: :policy do
  let(:user){ }
  let(:record){ create :message }
  subject{ MessagePolicy.new user, record }

  context 'without a user' do
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end

  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end

  context 'with an unconfirmed user' do
    let(:user){ create :user, confirmed_at: nil }
    it_behaves_like 'a policy forbidding', :index, :show, :create, :update, :destroy
  end

  context 'with a participant' do
    let(:user){ record.user }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end

  context 'with a moderator' do
    let(:user){ create :moderator, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with an admin' do
    let(:user){ create :admin, section: 'zooniverse' }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with scope' do
    let!(:other_records){ create_list :message, 2 }
    let(:user){ create :user }
    let(:records){ create_list :message, 2, user: user }
    subject{ MessagePolicy::Scope.new(user, Message).resolve }

    it{ is_expected.to match_array records }
  end
end
