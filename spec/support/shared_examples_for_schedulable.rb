shared_examples 'is schedulable' do
  let(:job) { Sidekiq::Cron::Job.new(name: 'cron_job_name', cron: cron_sched, class: class_name) }

  it 'gets queued on enqueued_times' do
    enqueued_times.each do |enqueued_time|
        job_enqueue_time = Time.at(job.formated_enqueue_time.to_f).utc
        expect(job_enqueue_time).to eq(enqueued_time)
    end
  end

  it 'does not get enqueued outside of enqueued_times' do
    outside_time = enqueued_times.first + 3 * 60

    expect(job.should_enque?(outside_time)).to be false
  end
end