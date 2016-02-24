require 'spec_helper'

RSpec.describe CollectionRefreshWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }

  describe 'schedule' do
    subject{ described_class.schedule.to_s }
    it{ is_expected.to match /Hourly on the 0th, 10th, 20th, 30th, 40th, and 50th minutes of the hour/ }
  end

  describe 'congestion' do
    subject{ CollectionRefreshWorker.new.sidekiq_options_hash['congestion'] }
    its([:interval]){ is_expected.to eql 1.hour }
    its([:max_in_interval]){ is_expected.to eql 10 }
    its([:min_delay]){ is_expected.to eql 5.minutes }
    its([:reject_with]){ is_expected.to eql :cancel }
  end

  describe '#perform' do
    it 'should refresh Collection search' do
      expect(Collection).to receive :refresh!
      subject.perform
    end
  end
end
