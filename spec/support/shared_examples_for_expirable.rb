require 'spec_helper'

RSpec.shared_examples_for 'an expirable model' do
  let(:fresh){ [] }
  let(:stale){ [] }

  describe '.expired' do
    it 'should find expired records' do
      expect(described_class.expired).to match_array stale
    end

    it 'should not include unexpired records' do
      expect(described_class.expired).to_not include fresh
    end
  end
end

RSpec.shared_examples_for 'an expiry worker' do |model:|
  it{ is_expected.to be_a Sidekiq::Worker }

  describe 'hourly schedule' do
    it_behaves_like 'is schedulable' do
      let(:cron_sched) { '0 * * * *' }
      let(:enqueue_time) { Fugit::Cron.parse(cron_sched).previous_time }
      let(:class_name) { described_class.name }
      let(:enqueued_times) {
        [
          enqueue_time.utc
        ]
      }
    end
  end

  describe '.model' do
    it 'should specify the model' do
      expect(described_class.model).to eql model
    end
  end

  describe '#perform' do
    it 'should destroy expired' do
      expect(described_class.model).to receive_message_chain 'expired.destroy_all'
      subject.perform
    end
  end
end
