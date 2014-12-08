require 'spec_helper'

RSpec.describe TagPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :tag }
  let(:subject){ TagPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
end
