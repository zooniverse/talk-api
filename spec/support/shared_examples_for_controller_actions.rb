require 'spec_helper'

RSpec.shared_examples_for 'a controller action' do
  let(:send_request){ send verb, action, params: params.merge(format: :json) }

  it 'should authorize the action' do
    if authorizable
      expect(subject).to receive(:authorize).with(authorizable).and_call_original
      send_request
    end
  end

  context 'with a response' do
    before(:each){ send_request }

    it 'should set the correct status' do
      expect(response.status).to eql status
    end

    it 'should be json' do
      # starting from Rails 5+, if responding with 204, content-type of response is set by Rails as nil
      expect(response.content_type).to eql 'application/json' unless response.status == 204
    end

    it 'should be an object' do
      expect(response.json).to be_a Hash
    end
  end

  describe '#enforce_ban' do
    let(:banned_user){ create :user, banned: true }
    before(:each) do
      allow(subject).to receive(:current_user).and_return banned_user
      send_request
    end

    it 'should be forbidden' do
      expect(response.status).to eql 403
    end

    it 'should respond with the correct error message' do
      expect(response.json[:error]).to eql 'You are banned'
    end
  end

  describe '#enforce_ip_ban' do
    let(:user){ create :user }
    let!(:banned_ip){ create :user_ip_ban }
    before(:each) do
      allow(subject).to receive(:current_user).and_return user
      request.env['REMOTE_ADDR'] = '1.2.3.4'
      send_request
    end

    it 'should be forbidden' do
      expect(response.status).to eql 403
    end

    it 'should respond with the correct error message' do
      expect(response.json[:error]).to eql 'You are banned'
    end
  end
end
