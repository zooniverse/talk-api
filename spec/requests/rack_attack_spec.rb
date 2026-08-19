# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate limiting', type: :request do
  let(:signing_key) { OpenSSL::PKey::RSA.generate(2048) }
  def jwt_token(user_id)
    JWT.encode({ 'data' => { 'id' => user_id } }, signing_key, 'RS512')
  end

  before(:each) do
    Rack::Attack.cache.store.clear
    allow(Rack::Attack).to receive(:jwt_signing_public_key).and_return(signing_key.public_key)
  end

  let(:user) { create(:user, id: 11223344) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_token(user.id)}" } }

  # For unauthenticated requests from a specific IP
  let(:ip) { '1.2.3.4' }
  let(:ip_headers) { { 'REMOTE_ADDR' => ip } }

  describe 'POST /conversations' do
    context 'with a standard user' do
      it 'allows requests up to the limit' do
        # test the rate limit, not the controller
        allow_any_instance_of(ConversationsController).to receive(:create).and_return(nil)
        10.times { post '/conversations', headers: auth_headers }
        expect(response.status).to eq(204)
      end

      it 'is throttled after the limit' do
        allow_any_instance_of(ConversationsController).to receive(:create).and_return(nil)
        55.times { post '/conversations', headers: auth_headers }
        expect(response.status).to eq(429)
      end
    end

    context 'with an user with an admin role' do
      before do
        Role.create!(user_id: user.id, name: 'admin', section: 'project-1')
      end

      it 'does not throttle requests from users with admin roles' do
        allow_any_instance_of(ConversationsController).to receive(:create).and_return(nil)

        60.times { post '/conversations', headers: auth_headers }
        expect(response.status).to eq(204)
      end
    end
  end

  describe 'POST /messages' do
    it 'allows requests up to the limit' do
      allow_any_instance_of(MessagesController).to receive(:create).and_return(nil)
      5.times do
        post '/messages', headers: auth_headers
        expect(response.status).to eq(204)
      end
    end

    it 'is throttled after the limit' do
      allow_any_instance_of(MessagesController).to receive(:create).and_return(nil)
      55.times { post '/messages', headers: auth_headers }
      expect(response.status).to eq(429)
    end

    it 'throttles based on token when IP is rotating' do
      allow_any_instance_of(MessagesController).to receive(:create).and_return(nil)
      55.times do |i|
        rotating_headers = auth_headers.merge('REMOTE_ADDR' => "10.0.0.#{i}")
        post '/messages', headers: rotating_headers
      end

      post '/messages', headers: auth_headers
      expect(response.status).to eq(429)
    end
  end

  describe 'GET /users?page=X' do
    it 'allows requests up to the limit' do
      allow_any_instance_of(UsersController).to receive(:index).and_return(nil)
      5.times do
        get '/users', params: { page: 10 }, headers: ip_headers
        expect(response.status).to eq(204)
      end
    end

    it 'is throttled after the limit' do
      allow_any_instance_of(UsersController).to receive(:index).and_return(nil)
      55.times { get '/users', params: { page: 10 } }
      get '/users', params: { page: 20 }
      expect(response.status).to eq(429)
    end
  end

  describe 'other unmatched routes hitting the limit' do
    it 'allows requests up to the limit' do
      allow_any_instance_of(CommentsController).to receive(:create).and_return(nil)
      5.times do
        post '/comments', headers: ip_headers
        expect(response.status).to eq(204)
      end
    end
  end

  describe 'Honeybadger notifications' do
    before do
      allow(Honeybadger).to receive(:notify)
    end

    it 'does not notify Honeybadger when under the limit' do
      post '/conversations', headers: auth_headers
      expect(Honeybadger).not_to have_received(:notify)
    end

    it 'sends a notification when the rate limit is hit' do
      55.times do
        post '/conversations', headers: auth_headers
      end

      expect(Honeybadger).to receive(:notify).with(
        "Rack::Attack Rate Limit Triggered: conversations/create/user",
        hash_including(
          error_class: "RateLimitExceeded",
          context: hash_including(
            throttle: "conversations/create/user",
            ip: "127.0.0.1",
            user_id: user.id,
            path: "/conversations",
            method: "POST"
          )
        )
      )

      post '/conversations', headers: auth_headers
    end

    it 'sends a notification for POST rate limit tracking' do
      55.times { post '/comments', headers: auth_headers }

      expect(Honeybadger).to receive(:notify).with(
        "Rack::Attack Rate Limit Triggered: post/ip",
        hash_including(
          error_class: "RateLimitExceeded",
          context: hash_including(
            throttle: "post/ip",
            ip: "127.0.0.1",
            user_id: user.id
          )
        )
      )

      post '/comments', headers: auth_headers
    end
  end

  describe 'JWT token verification' do
    before do
      allow_any_instance_of(ConversationsController).to receive(:create).and_return(nil)
    end

    it 'loads the correct key for the current environment' do
      allow(Rack::Attack).to receive(:jwt_signing_public_key).and_call_original
      allow(File).to receive(:read).with('/rails_app/config/keys/doorkeeper-jwt-test.pub').and_return(signing_key.public_key)

      expect(Rack::Attack).to receive(:key_file_path).and_return(Rails.root.join('config', 'keys', "doorkeeper-jwt-#{Rails.env}.pub").to_s)
      Rack::Attack.jwt_signing_public_key
    end

    it 'throttles based on user ID from a valid signed token' do
      20.times do |i|
        post '/conversations', headers: auth_headers.merge('REMOTE_ADDR' => "10.0.0.#{i}")
      end

      expect(response.status).to eq(429)
    end

    # Somebody else's key, invalid for our public key
    let(:spooky_signing_key) { OpenSSL::PKey::RSA.generate(2048) }

    it 'does not use the user ID from a token with an invalid signature' do
      invalid_token = JWT.encode( { 'data' => { 'id' => user.id } }, spooky_signing_key, 'RS512')

      # Rotate IP to test only user throttling
      20.times do |i|
        post '/conversations', headers: { 'Authorization' => "Bearer #{invalid_token}", 'REMOTE_ADDR' => "10.0.0.#{i}" }
      end

      # Req still allowed, so user ID from invalid token wasn't used for throttling
      expect(response.status).to eq(204)
    end

    it 'rejects unsigned tokens' do
      unsigned_token = JWT.encode( { 'data' => { 'id' => user.id } }, nil, 'none')

      20.times do |i|
        post '/conversations', headers: { 'Authorization' => "Bearer #{unsigned_token}", 'REMOTE_ADDR' => "10.0.0.#{i}" }
      end

      expect(response.status).to eq(204)
    end
  end
end
