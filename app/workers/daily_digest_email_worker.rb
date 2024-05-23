class DailyDigestEmailWorker
  include DigestEmailWorker
  self.frequency = :daily
end
