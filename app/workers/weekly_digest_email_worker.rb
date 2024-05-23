class WeeklyDigestEmailWorker
  include DigestEmailWorker
  self.frequency = :weekly
end
