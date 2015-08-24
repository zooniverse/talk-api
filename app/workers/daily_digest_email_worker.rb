class DailyDigestEmailWorker
  include DigestEmailWorker
  self.frequency = :daily
  
  recurrence do
    daily.hour_of_day 6
  end
end
