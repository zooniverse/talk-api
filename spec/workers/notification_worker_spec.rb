require 'spec_helper'

RSpec.describe NotificationWorker, type: :worker do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe '#perform' do
    let(:notification){ create :notification }
    
    it 'should notify via sugar' do
      expect(Sugar).to receive(:notify).with notification
      subject.perform notification.id
    end
  end
end
