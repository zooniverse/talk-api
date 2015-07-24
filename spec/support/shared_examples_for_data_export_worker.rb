require 'spec_helper'

RSpec.shared_examples_for 'a data export worker' do
  it{ is_expected.to be_a Sidekiq::Worker }
  let!(:data_request){ create :data_request }
  
  describe '#compress' do
    let!(:in_file){ File.new __FILE__ }
    let(:out_file){ '/tmp/some_name.tar.gz' }
    let(:file_name){ File.basename in_file.path }
    let(:file_path){ File.dirname in_file.path }
    
    before(:each) do
      subject.name = 'some_name'
      allow(subject).to receive :'`'
      allow(File).to receive(:new).with(out_file).and_return 'works'
    end
    
    it 'should run the correct command' do
      expected_command = "cd #{ file_path } && tar czf #{ out_file } #{ file_name }"
      expect(subject).to receive(:'`').with expected_command
      subject.compress in_file
    end
    
    it 'should return the output file' do
      expect(subject.compress(in_file)).to eql 'works'
    end
  end
  
  describe '#write_data' do
    let(:output){ double }
    before(:each) do
      subject.name = 'some_name'
      allow(File).to receive(:open).with("some_name.json", 'w').and_return output
    end
    
    def expect_write(written)
      expect(output).to receive(:write).once.ordered.with written
    end
    
    def expect_close
      expect(output).to receive :close
    end
    
    context 'with no rows' do
      before(:each) do
        allow(subject).to receive :each_row
      end
      
      it 'should write an empty array' do
        expect_write '['
        expect_write "]\n"
        expect_close
        subject.write_data
      end
    end
    
    context 'with multiple rows' do
      before(:each) do
        allow(subject).to receive(:each_row)
          .and_yield({ first: 'works' }, 0)
          .and_yield({ second: 'also works' }, 1)
      end
      
      it 'should write an empty array' do
        expect_write '['
        expect_write '{"first":"works"}'
        expect_write ','
        expect_write '{"second":"also works"}'
        expect_write "]\n"
        expect_close
        subject.write_data
      end
    end
  end
  
  describe '#each_row' do
    before(:each) do
      allow(subject).to receive(:find_each)
        .and_yield(a: 1)
        .and_yield(b: 2)
    end
    
    it 'should call #row_from' do
      expect(subject).to receive(:row_from).with a: 1
      expect(subject).to receive(:row_from).with b: 2
      subject.each_row{ }
    end
    
    it 'should yield the row with index' do
      allow(subject).to receive(:row_from){ |row| row }
      
      expect do |block|
        subject.each_row &block
      end.to yield_successive_args([{ a: 1 }, 0], [{ b: 2 }, 1])
    end
  end
  
  describe '#process_data' do
    let(:written_data){ double }
    let(:gzipped_data){ double }
    let(:uploader){ double upload: true, url: 'location' }
    
    before(:each) do
      subject.name = 'some_name'
      subject.data_request = data_request
      allow(subject).to receive(:write_data).and_return written_data
      allow(subject).to receive(:compress).and_return gzipped_data
      expect(Uploader).to receive(:new).with(gzipped_data).and_return uploader
      allow(File).to receive(:unlink)
    end
    
    it 'should write the data' do
      expect(subject).to receive :write_data
      subject.process_data
    end
    
    it 'should compress the data' do
      expect(subject).to receive(:compress).with written_data
      subject.process_data
    end
    
    it 'should unlink the created files' do
      expect(File).to receive(:unlink).once.ordered.with written_data
      expect(File).to receive(:unlink).once.ordered.with gzipped_data
      subject.process_data
    end
    
    it 'should upload the gzipped file' do
      expect(uploader).to receive :upload
      subject.process_data
    end
    
    it 'should create the notification' do
      expect(data_request).to receive(:notify_user)
        .with message: "Your data export of some_name is ready", url: uploader.url
      subject.process_data
    end
  end
  
  describe '#perform' do
    let(:user){ create :user }
    
    before(:each) do
      allow(DataRequest).to receive(:find).with(data_request.id).and_return data_request
      allow(subject).to receive :process_data
      allow(Time).to receive_message_chain('now.utc.to_date.to_s'){ '2015-07-21' }
    end
    
    it 'should set the data request' do
      subject.perform data_request.id
      expect(subject.data_request).to eql data_request
    end
    
    it 'should set the name' do
      subject.perform data_request.id
      expect(subject.name).to eql "#{ data_request.section }-#{ data_request.kind }_2015-07-21"
    end
    
    it 'should process the data' do
      expect(subject).to receive :process_data
      subject.perform data_request.id
    end
    
    it 'should set the data request started' do
      expect(data_request).to receive :started!
      subject.perform data_request.id
    end
    
    it 'should set the data request finished' do
      expect(data_request).to receive :finished!
      subject.perform data_request.id
    end
    
    it 'should indicate failure' do
      allow(subject).to receive(:process_data).and_raise 'hell'
      
      expect{
        subject.perform data_request.id
      }.to raise_error 'hell'
      
      expect(data_request).to be_failed
    end
  end
end
