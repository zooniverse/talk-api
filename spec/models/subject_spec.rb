require 'spec_helper'

RSpec.describe Subject, type: :model do
  let(:subject){ create :subject }
  it_behaves_like 'moderatable'
  
  it 'should include media' do
    expect(subject.locations.first).to be_a Medium
  end
end
