require 'spec_helper'

RSpec.shared_examples_for 'a controller authenticating' do
  context 'without a user' do
    before(:each){ get :root }
    its(:bearer_token){ is_expected.to be nil }
    its(:current_user){ is_expected.to be nil }
    its(:panoptes){ is_expected.to be_a PanoptesProxy }
    its('panoptes.token'){ is_expected.to be nil }
  end
  
  context 'with a user' do
    include_examples 'panoptes requests'
    
    before :each do
      @request.headers['Authorization'] = "Bearer #{ bearer_token }"
      stub_successful_me_request
      get :root
    end
    
    its(:bearer_token){ is_expected.to eql bearer_token }
    its(:current_user){ is_expected.to eql current_user }
    its('panoptes.token'){ is_expected.to eql bearer_token }
  end
end
