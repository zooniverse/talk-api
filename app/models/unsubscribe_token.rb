require 'securerandom'

class UnsubscribeToken < ApplicationRecord
  include Expirable
  belongs_to :user
  before_create :set_expiration, :set_token!

  def self.for_user(user)
    tries = 0
    begin
      where(user: user).first_or_create.tap do |token|
        token.update_attribute :expires_at, 1.month.from_now.utc
      end
    rescue ActiveRecord::RecordNotUnique => e
      tries += 1
      tries < 5 ? retry : raise(e)
    end
  end

  def set_token!
    tries = 0
    begin
      self.token = SecureRandom.hex 20
      save! unless new_record?
    rescue ActiveRecord::RecordNotUnique => e
      tries += 1
      tries < 5 ? retry : raise(e)
    end
  end

  protected

  def set_expiration
    self.expires_at ||= 1.month.from_now.utc
  end
end
