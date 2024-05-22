module ExpiryWorker
  extend ActiveSupport::Concern

  included do
    include Sidekiq::Worker

    class << self
      attr_accessor :model
    end

    sidekiq_options retry: false, backtrace: true
  end

  def perform
    self.class.model.expired.destroy_all
  end
end
