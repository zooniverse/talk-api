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
      expect(subject).to receive(:section_tags).at_least(:once).and_call_original
      subject.find_each{ }
    end

    it 'should iterate tags' do
      scope = Tag.where section: 'project-1'
      expect(Tag).to receive(:where).at_least(:once).and_return scope
      expect(scope).to receive(:find_each).and_call_original
      expect do |block|
        subject.find_each &block
      end.to yield_successive_args tag
    end

    it 'should use the batch size' do
      expect(subject).to receive(:batch_size).and_return 123
      enumerator = double find_each: nil
      expect(subject).to receive(:section_tags).and_return enumerator
      expect(enumerator).to receive(:find_each).with batch_size: 123
      subject.find_each{ }
    end
  end

  describe '#section_tags' do
    let!(:tag){ create :tag, section: 'project-1' }
    before(:each){ subject.data_request = create :data_request, section: 'project-1' }

    it 'should scope tags to section' do
      expect(Tag).to receive(:where).with(section: 'project-1').and_call_original
      subject.section_tags
    end
  end

  describe '#row_count' do
    it 'should count section tags' do
      expect(subject).to receive(:section_tags).and_return double count: 5
      expect(subject.row_count).to eql 5
    end
  end
end
