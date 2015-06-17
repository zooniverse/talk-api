require 'spec_helper'

RSpec.shared_examples_for 'panoptes requests' do
  let(:current_user){ create :user }
  let(:bearer_token){ 'bearer_token' }
  
  let(:stub_successful_me_request){ me_request.to_return successful_me_response }
  
  let(:me_request) do
    stub_request(:get, "#{ PanoptesProxy.host }/api/me").with headers: {
        'Accept' => 'application/vnd.api+json; version=1',
        'Authorization' => "Bearer #{ bearer_token }",
        'Content-Type' => 'application/json'
      }
  end
  
  let(:successful_me_response) do
    {
      status: 200,
      headers: {
        'Content-Type' => 'application/vnd.api+json; version=1'
      },
      body: JSON.dump({
        users: [
          {
            id: current_user.id.to_s,
            login: current_user.login,
            display_name: current_user.display_name,
            credited_name: nil,
            email: current_user.email,
            created_at: Time.now.utc,
            updated_at: Time.now.utc,
            owner_name: current_user.login,
            links: { }
          }
        ],
        links: { },
        meta: {
          users: {
            page: 1,
            page_size: 20,
            count: 1,
            include: [ ],
            page_count: 1,
            previous_page: nil,
            next_page: nil,
            first_href: '/users',
            previous_href: nil,
            next_href: nil,
            last_href: '/users'
          }
        }
      })
    }
  end
end
