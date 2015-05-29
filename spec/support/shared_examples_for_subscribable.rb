require 'spec_helper'

RSpec.shared_examples_for 'a subscribable model' do
  let(:source){ create described_class }
  let!(:subscriptions){ create_list :subscription, 2, source: source }
  
  it 'should have subscriptions' do
    expect(source.subscriptions).to match_array subscriptions
  end
end
