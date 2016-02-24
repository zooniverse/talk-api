module Expirable
  extend ActiveSupport::Concern

  included do
    scope :expired, ->{ where 'expires_at < ?', Time.now.utc }
  end

  module ClassMethods
    def expires_in(amount)
      scope :expired, ->{ where 'created_at < ?', amount.ago.utc }
    end
  end
end
