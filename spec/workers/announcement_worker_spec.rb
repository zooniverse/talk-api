require 'spec_helper'

RSpec.describe AnnouncementWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe '#perform' do
    let(:announcement){ create :announcement }
    
    it 'should notify via sugar' do
      expect(Sugar).to receive(:announce).with announcement
      subject.perform announcement.id
    end
  end
end
