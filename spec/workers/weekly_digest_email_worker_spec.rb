require 'spec_helper'

RSpec.describe WeeklyDigestEmailWorker, type: :worker do
  it_behaves_like 'a digest email worker', scope: :weekly
  its('class.schedule.to_s'){ is_expected.to eql 'Weekly on Mondays on the 12th hour of the day' }
end
