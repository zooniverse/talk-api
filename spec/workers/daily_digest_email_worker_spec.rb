require 'spec_helper'

RSpec.describe DailyDigestEmailWorker, type: :worker do
  it_behaves_like 'a digest email worker', scope: :daily
  its('class.schedule.to_s'){ is_expected.to eql 'Daily on the 6th hour of the day' }
end
