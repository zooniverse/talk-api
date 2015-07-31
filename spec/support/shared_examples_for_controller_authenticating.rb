require 'spec_helper'

RSpec.shared_examples_for 'a controller authenticating' do |controller_action = :index|
  context 'without a user' do
    before(:each){ get controller_action }
    its(:bearer_token){ is_expected.to be nil }
    its(:current_user){ is_expected.to be nil }
  end
  
  context 'with a user' do
    let(:current_user){ create :user }
    let(:bearer_token){ create(:oauth_access_token, resource_owner: current_user).token }
    
    before :each do
      @request.headers['Authorization'] = "Bearer #{ bearer_token }"
      get controller_action
    end
    
    its(:bearer_token){ is_expected.to eql bearer_token }
    its(:current_user){ is_expected.to eql current_user }
  end
end
