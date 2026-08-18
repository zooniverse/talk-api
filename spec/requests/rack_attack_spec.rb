# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate limiting', type: :request do
  def jwt_token(user_id)
    JWT.encode({ sub: user_id }, nil, 'none')
  end

  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token(user.id)}" } }

  describe 'POST /conversations' do
    it 'allows requests up to the limit' do
      # test the rate limit, not the controller
      allow_any_instance_of(ConversationsController).to receive(:create).and_return(nil)
      10.times do
        post '/conversations', headers: headers
        expect(response.status).to eq(204)
      end
    end

    it 'is throttled after the limit' do
      allow_any_instance_of(ConversationsController).to receive(:create).and_return(nil)
      50.times { post '/conversations', headers: headers }
      expect(response.status).to eq(429)
    end
  end

  describe 'POST /messages' do
    it 'allows requests up to the limit' do
      allow_any_instance_of(MessagesController).to receive(:create).and_return(nil)
      5.times do
        post '/messages', headers: headers
        expect(response.status).to eq(204)
      end
    end

    it 'is throttled after the limit' do
      allow_any_instance_of(MessagesController).to receive(:create).and_return(nil)
      50.times { post '/messages', headers: headers }
      post '/messages', headers: headers
      expect(response.status).to eq(429)
    end
  end

  describe 'GET /users' do
    it 'allows requests up to the limit' do
      allow_any_instance_of(UsersController).to receive(:index).and_return(nil)
      5.times do
        get '/users', params: { page: 10 }
        expect(response.status).to eq(204)
      end
    end

    it 'is throttled after the limit' do
      allow_any_instance_of(UsersController).to receive(:index).and_return(nil)
      50.times { get '/users', params: { page: 10 } }
      get '/users', params: { page: 20 }
      expect(response.status).to eq(429)
    end
  end

  describe 'other unmatched routes hitting the limit' do
    it 'allows requests up to the limit' do
      allow_any_instance_of(CommentsController).to receive(:create).and_return(nil)
      5.times do
        post '/comments'
        expect(response.status).to eq(204)
      end
    end

    it 'is throttled after repeated requests' do
      allow_any_instance_of(CommentsController).to receive(:create).and_return(nil)
      100.times { post '/comments' }
      post '/comments'
      expect(response.status).to eq(429)
    end
  end
end
