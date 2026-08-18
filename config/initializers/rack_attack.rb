# frozen_string_literal: true

require 'rack/attack'

class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  )

  def self.throttled_user_id(req)
    auth = req.get_header('HTTP_AUTHORIZATION')
    return nil unless auth&.start_with?('Bearer ')
    token = auth.split(' ').last
    user_id = JWT.decode(token, nil, false)&.first&.dig('data', 'id')

    # Skip the throttle if unauthenticated OR if the user is an admin
    return nil if user_id.nil? || Role.exists?(user_id: user_id, name: 'admin')

    user_id
  end

  # New conversations
  throttle('conversations/create/user', limit: 10, period: 1.hour) do |req|
    throttled_user_id(req) if req.path == '/conversations' && req.post?
  end

  throttle('conversations/create/ip', limit: 10, period: 1.hour) do |req|
    throttled_user_id(req) if req.path == '/conversations' && req.post?
  end

  # Replies to existing conversations
  throttle('messages/create/user', limit: 20, period: 1.hour) do |req|
    throttled_user_id(req) if req.path == '/messages' && req.post?
  end

  throttle('messages/create/ip', limit: 20, period: 1.hour) do |req|
    throttled_user_id(req) if req.path == '/messages' && req.post?
  end

  # User enumeration
  throttle('users/index/ip', limit: 20, period: 5.minutes) do |req|
    req.ip if req.path == '/users' && req.get? && req.params['page'].present?
  end

  # General POST limit per IP. Track & notify only (no throttle)
  track('post/ip', limit: 50, period: 5.minutes) do |req|
    req.ip if req.post?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data'] || {}
    retry_after = match_data[:period]
    [ 429, { 'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s },
      [{ errors: [{ message: "Rate limit exceeded." }] }.to_json]
    ]
  end

  # Notify Honeybadger when a throttle/track is triggered
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    request = payload[:request]
    if [:throttle, :track].include?(request.env['rack.attack.match_type'])
      throttle_name = request.env['rack.attack.matched']
      match_data    = request.env['rack.attack.match_data'] || {}

      Honeybadger.notify(
        "Rack::Attack Rate Limit Triggered: #{throttle_name}",
        error_class: "RateLimitExceeded",
        context: {
          throttle: throttle_name,
          ip: request.ip,
          path: request.path,
          user_id: throttled_user_id(request),
          method: request.request_method,
          period: match_data[:period],
          limit: match_data[:limit],
          count: match_data[:count]
        }
      )
    end
  end
end
