require 'spec_helper'

RSpec.shared_examples_for 'an api resource' do |attributes: [], updateable: []|
  let(:api_record){ { } }
  let(:body){ { described_class.table_name => [api_record] } }
  let(:status){ 200 }
  let(:from_panoptes){ described_class.from_panoptes api_response }
  let(:api_response) do
    success = status >= 200 && status < 300
    OpenStruct.new success?: success, status: status, body: body
  end
  
  describe '.panoptes_attributes' do
    subject{ described_class.panoptes_attributes }
    
    attributes.each do |attribute|
      it{ is_expected.to have_key attribute }
    end
    
    updateable.each do |attribute|
      its([attribute]){ is_expected.to include updateable: true }
    end
  end
  
  describe '.from_panoptes' do
    context 'when panoptes fails' do
      let(:status){ 500 }
      
      it 'should be nil' do
        expect(from_panoptes).to be nil
      end
    end
    
    it 'should find or create the record' do
      expect(described_class).to receive(:find_or_create_from_panoptes)
        .with(api_record).and_call_original
      from_panoptes
    end
    
    it 'should update the record' do
      expect_any_instance_of(described_class).to receive(:update_from_panoptes)
        .with(api_record).and_call_original
      from_panoptes
    end
    
    it 'should return a record' do
      expect(from_panoptes).to be_a described_class
    end
  end
  
  describe '.find_or_create_from_panoptes' do
    context 'with an existing record' do
      let!(:existing){ create described_class, id: api_record['id'] }
      
      it 'should not create a record' do
        expect(described_class).to_not receive(:create)
        from_panoptes
      end
    end
    
    context 'with a new record' do
      it 'should try to find the record first' do
        expect(described_class).to receive(:find_by_id).with api_record['id']
        from_panoptes
      end
      
      it 'should create the record' do
        expect(described_class).to receive(:create)
          .with(api_record).and_call_original
        from_panoptes
      end
    end
  end
  
  describe '#update_from_panoptes' do
    let(:updateable_attributes){ updateable.map &:to_s }
    let(:unchanging){ existing.attributes.except *updateable_attributes }
    
    context 'with changes' do
      let!(:existing){ create described_class, id: api_record['id'] }
      
      it 'should update attributes' do
        record = from_panoptes
        changes = record.attributes.slice *updateable_attributes
        expect(changes.keys).to match_array updateable_attributes
      end
      
      it 'should save the record' do
        expect_any_instance_of(described_class).to receive :save!
        from_panoptes
      end
    end
    
    context 'without changes' do
      let!(:existing){ from_panoptes }
      
      it 'should not call save' do
        expect_any_instance_of(described_class).to_not receive :save!
        from_panoptes
      end
    end
  end
end
