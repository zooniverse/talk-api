require 'spec_helper'

RSpec.shared_examples_for 'a subscribable model' do
  let(:source){ create described_class }
  let!(:subscriptions){ create_list :subscription, 2, source: source }
  
  it 'should have subscriptions' do
    expect(source.subscriptions).to match_array subscriptions
  end
  
  it 'should remove subscriptions when destroying the source' do
    expect {
      source.destroy
    }.to change {
      Subscription.where(source: source).count
    }.from(2).to 0
  end
end
