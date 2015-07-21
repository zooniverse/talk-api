require 'spec_helper'

RSpec.describe TagExportWorker, type: :worker do
  it_behaves_like 'a data export worker'
  
  it 'should set the name' do
    expect(TagExportWorker.name).to eql 'tags'
  end
  
  describe '#row_from' do
    let(:tag){ create :tag }
    subject{ described_class.new.row_from tag }
    it{ is_expected.to eql tag.attributes.except('updated_at') }
  end
  
  describe '#find_each' do
    before(:each){ subject.section = 'project-1' }
    let!(:tag){ create :tag, section: subject.section }
    
    it 'should tags to section' do
      expect(Tag).to receive(:where).once.with(section: 'project-1').and_call_original
      subject.find_each{ }
    end
    
    it 'should iterate tags' do
      block = Proc.new{ }
      scope = Tag.where section: 'project-1'
      expect(Tag).to receive(:where).and_return scope
      expect(scope).to receive(:find_each).and_call_original
      expect do |block|
        subject.find_each &block
      end.to yield_successive_args tag
    end
  end
end
