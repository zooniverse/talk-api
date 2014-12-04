require 'spec_helper'

RSpec.shared_examples_for 'moderatable' do
  let(:name){ described_class.name.tableize.singularize.to_sym }
  let(:moderatable){ create name }
  
  it 'should have a moderation' do
    moderation = create :moderation, target: moderatable
    expect(moderatable.moderation).to eql moderation
  end
  
  describe '.moderatable_with' do
    let(:dummy){ Class.new moderatable.class }
    
    it 'should create moderatable actions' do
      expect {
        dummy.moderatable_with :foo, by: [:bar, :baz]
      }.to change {
        dummy.moderatable[:foo]
      }.to bar: true, baz: true
    end
    
    it 'should not affect a parent class' do
      expect {
        dummy.moderatable_with :foo, by: [:bar, :baz]
      }.to_not change {
        moderatable.class.moderatable
      }
    end
    
    it 'should override inherited actions' do
      dummy.moderatable_with :bar, by: [:baz]
      sub_class = Class.new dummy
      
      expect {
        sub_class.moderatable_with :bar, by: [:foo]
      }.to change {
        sub_class.moderatable[:bar]
      }.from(baz: true).to foo: true
    end
  end
end
