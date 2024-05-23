require 'spec_helper'

RSpec.describe WeeklyDigestEmailWorker, type: :worker do
  it_behaves_like 'a digest email worker', scope: :weekly
  it_behaves_like 'is schedulable' do
    let(:cron_sched) { '0 12 * * 1' }
      let(:enqueue_time) { Fugit::Cron.parse(cron_sched).previous_time }
      let(:class_name) { described_class.name }
      let(:enqueued_times) {
        [
          enqueue_time.utc
        ]
      }
  end
end
