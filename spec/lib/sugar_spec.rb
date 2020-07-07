require 'spec_helper'

RSpec.describe Sugar, type: :lib do
  subject{ Sugar }

  # before(:each){ reset_config }
  # after(:each){ reset_config }

  before(:each) do
    allow(Sugar).to receive(:config).and_return({
      host: 'host',
      username: 'username',
      password: 'password'
    })
  end

  shared_examples_for 'a sugar request' do
    let(:authorization) do
      credentials = "#{ Sugar.config[:username] }:#{ Sugar.config[:password] }"
      Base64.encode64(credentials).chomp
    end

    let!(:stubbed_request) do
      stub_request(:post, "http://sugar.localhost/#{ method }")
        .with body: body.to_json, headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => "Basic #{ authorization }"
        }
    end

    it 'should set request headers' do
      Sugar.send method, object
      expect(stubbed_request).to have_been_requested.once
    end
  end

  describe '.notify' do
    it_behaves_like 'a sugar request' do
      let(:method){ :notify }
      let(:object){ create :notification }
      let(:body){ { notifications: [object] } }
    end
  end

  describe '.announce' do
    it_behaves_like 'a sugar request' do
      let(:method){ :announce }
      let(:object){ create :announcement }
      let(:body){ { announcements: [object] } }
    end
  end
end
