# frozen_string_literal: true

require 'rack/attack'

class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  )

  def self.hashed_token(req)
    auth = req.env['HTTP_AUTHORIZATION']
    return nil if auth.blank?
    Digest::SHA256.hexdigest(auth)
  end

  # New conversations
  throttle('conversations/create/user', limit: 10, period: 1.hour) do |req|
    hashed_token(req) if req.path == '/conversations' && req.post?
  end

  throttle('conversations/create/ip', limit: 10, period: 1.hour) do |req|
    req.ip if req.path == '/conversations' && req.post?
  end

  # Replies to existing conversations
  throttle('messages/create/user', limit: 20, period: 1.hour) do |req|
    hashed_token(req) if req.path == '/messages' && req.post?
  end

  throttle('messages/create/ip', limit: 20, period: 1.hour) do |req|
    req.ip if req.path == '/messages' && req.post?
  end

  # User enumeration
  throttle('users/index/ip', limit: 20, period: 5.minutes) do |req|
    req.ip if req.path == '/users' && req.get? && req.params['page'].present?
  end

  # General POST limit
  throttle('post/ip', limit: 50, period: 5.minutes) do |req|
    req.ip if req.post?
  end

  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data'] || {}
    retry_after = match_data[:period]
    [ 429, { 'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s },
      [{ errors: [{ message: "Rate limit exceeded." }] }.to_json]
    ]
  end
end
