require 'spec_helper'

RSpec.describe TagExportWorker, type: :worker do
  it_behaves_like 'a data export worker'
  
  describe '#row_from' do
    let(:tag){ create :tag }
    subject{ described_class.new.row_from tag }
    it{ is_expected.to eql tag.attributes.except('updated_at') }
  end
  
  describe '#find_each' do
    let!(:tag){ create :tag, section: 'project-1' }
    before(:each){ subject.data_request = create :data_request, section: 'project-1' }
    
    it 'should scope tags to section' do
      expect(Tag).to receive(:where).once.with(section: 'project-1').and_call_original
      subject.find_each{ }
    end
    
    it 'should iterate tags' do
      scope = Tag.where section: 'project-1'
      expect(Tag).to receive(:where).and_return scope
      expect(scope).to receive(:find_each).and_call_original
      expect do |block|
        subject.find_each &block
      end.to yield_successive_args tag
    end
  end
end
