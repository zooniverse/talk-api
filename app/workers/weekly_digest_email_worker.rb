class WeeklyDigestEmailWorker
  include DigestEmailWorker
  self.frequency = :weekly

  recurrence do
    weekly.day(:monday).hour_of_day 12
  end
end
