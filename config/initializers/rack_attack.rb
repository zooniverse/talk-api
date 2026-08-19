# frozen_string_literal: true
require 'rack/attack'

class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  )

  def self.current_user_id(req)
    auth = req.get_header('HTTP_AUTHORIZATION')
    return nil unless auth&.start_with?('Bearer ')

    token = auth.split(' ').last
    begin
      decode_token(token)&.dig('data', 'id')
    rescue JWT::DecodeError
      nil
    end
  end

  def self.decode_token(token)
    JWT.decode(token, jwt_signing_public_key, true, algorithm: 'RS512').first
  end

  def self.key_file_path
    Rails.root.join('config', 'keys', "doorkeeper-jwt-#{Rails.env.to_s}.pub").to_s
  end

  def self.jwt_signing_public_key
    @jwt_signing_public_key ||= OpenSSL::PKey::RSA.new(File.read(key_file_path))
  end

  def self.admin?(req)
    user_id = current_user_id(req)
    user_id.present? && Role.exists?(user_id: user_id, name: 'admin')
  end

  # New conversations
  throttle('conversations/create/user', limit: 10, period: 1.hour) do |req|
    current_user_id(req) if req.path == '/conversations' && req.post? && !admin?(req)
  end

  throttle('conversations/create/ip', limit: 10, period: 1.hour) do |req|
    req.ip if req.path == '/conversations' && req.post? && !admin?(req)
  end

  # Replies to existing conversations
  throttle('messages/create/user', limit: 20, period: 1.hour) do |req|
    current_user_id(req) if req.path == '/messages' && req.post? && !admin?(req)
  end

  throttle('messages/create/ip', limit: 20, period: 1.hour) do |req|
    req.ip if req.path == '/messages' && req.post? && !admin?(req)
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
          user_id: current_user_id(request),
          method: request.request_method,
          period: match_data[:period],
          limit: match_data[:limit],
          count: match_data[:count]
        }
      )
    end
  end
end
