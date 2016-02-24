module ExpiryWorker
  extend ActiveSupport::Concern

  included do
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    class << self
      attr_accessor :model
    end

    sidekiq_options retry: false, backtrace: true
    recurrence{ hourly }
  end

  def perform
    self.class.model.expired.destroy_all
  end
end
