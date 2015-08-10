require 'spec_helper'

RSpec.shared_examples_for 'a notifiable model' do
  let(:source){ create described_class }
  let!(:notification){ create :notification, source: source }
  subject{ source }
  
  it 'should remove notifications when destroying the source' do
    expect {
      source.destroy
    }.to change {
      Notification.where(source: source).count
    }.from(1).to 0
  end
end
