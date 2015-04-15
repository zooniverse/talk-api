class CollectionRefreshWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  sidekiq_options congestion: {
    interval: 1.hour,
    max_in_interval: 10,
    min_delay: 5.minutes,
    reject_with: :cancel
  }, retry: false, backtrace: true
  
  recurrence do
    every_ten_minutes = (0...60).step(10).to_a
    hourly.minute_of_hour *every_ten_minutes
  end
  
  def perform
    ::Collection.refresh!
  end
end
