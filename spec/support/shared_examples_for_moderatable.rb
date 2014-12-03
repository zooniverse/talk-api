require 'spec_helper'

RSpec.shared_examples_for 'moderatable' do
  let(:name){ described_class.name.tableize.singularize.to_sym }
  let(:moderatable){ create name }
  
  it 'should have a moderation' do
    moderation = create :moderation, target: moderatable
    expect(moderatable.moderation).to eql moderation
  end
end
