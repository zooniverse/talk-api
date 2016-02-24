class OauthAccessToken < ActiveRecord::Base
  belongs_to :resource_owner, class_name: 'User'

  class ExpiredError < StandardError
    def message; 'Access Token has expired'; end
    alias_method :to_s, :message
  end

  class RevokedError < StandardError
    def message; 'Access Token has been revoked'; end
    alias_method :to_s, :message
  end

  def resource_owner
    super.tap do |user|
      raise ExpiredError if expired?
      raise RevokedError if revoked?
    end
  end

  def expired?
    Time.now.utc > created_at + expires_in.seconds
  end

  def revoked?
    !!revoked_at
  end
end
