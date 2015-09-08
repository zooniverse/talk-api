require 'spec_helper'

RSpec.shared_examples_for 'moderatable' do
  let(:name){ described_class.name.tableize.singularize.to_sym }
  let(:moderatable){ create name }
  let!(:moderation){ create :moderation, target: moderatable }
  
  it 'should have a moderation' do
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
  
  describe '#close_moderation' do
    context 'without a moderation' do
      it 'should not close the moderation' do
        moderation.destroy
        expect{
          moderatable.destroy
        }.to_not raise_error
      end
    end
    
    context 'with a moderation' do
      before :each do
        allow(moderatable).to receive(:moderation).and_return moderation
      end
      
      context 'with an ignored moderation' do
        it 'should not close the moderation' do
          moderation.update state: 'ignored'
          expect(moderation).to_not receive :save
          moderatable.destroy
        end
      end
      
      context 'with an open moderation' do
        before(:each){ moderatable.destroy }
        subject{ moderation.reload }
        its(:state){ is_expected.to eql 'closed' }
        its(:destroyed_target){ is_expected.to include 'id' => moderatable.id }
        its(:target){ is_expected.to be_nil }
      end
    end
  end
end
