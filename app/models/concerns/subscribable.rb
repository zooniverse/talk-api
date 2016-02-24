module Subscribable
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, as: :source, dependent: :destroy
  end
end
