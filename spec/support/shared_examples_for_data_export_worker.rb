require 'spec_helper'

RSpec.shared_examples_for 'a data export worker' do
  it{ is_expected.to be_a Sidekiq::Worker }
  
  describe 'congestion' do
    subject{ described_class.new.sidekiq_options_hash['congestion'] }
    its([:interval]){ is_expected.to eql 1.day }
    its([:max_in_interval]){ is_expected.to eql 1 }
    its([:min_delay]){ is_expected.to eql 1.day }
    its([:reject_with]){ is_expected.to eql :cancel }
  end
  
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
    let(:project){ create :project }
    let(:section){ "project-#{ project.id }" }
    let(:user){ create :user }
    let(:written_data){ double }
    let(:gzipped_data){ double }
    let(:uploader){ double upload: true, url: 'location' }
    
    before(:each) do
      subject.name = 'some_name'
      expect(subject).to receive(:section).and_return section
      allow(subject).to receive(:user).and_return user
      allow(subject).to receive(:write_data).and_return written_data
      allow(subject).to receive(:compress).and_return gzipped_data
      expect(Uploader).to receive(:new).with(gzipped_data).and_return uploader
      allow(Project).to receive(:from_section).with(section).and_return project
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
      expect(project).to receive(:create_system_notification).with user,
        message: "Your data export of some_name is ready", url: uploader.url
      subject.process_data
    end
  end
  
  describe '#perform' do
    let(:section){ 'project-1' }
    let(:user){ create :user }
    
    before(:each) do
      expect(subject).to receive :process_data
      allow(described_class).to receive(:name).and_return 'some_name'
      allow(Time).to receive_message_chain('now.utc.to_date.to_s'){ '2015-07-21' }
      subject.perform section, user.id
    end
    
    its(:section){ is_expected.to eql section }
    its(:name){ is_expected.to eql "#{ section }-some_name_2015-07-21" }
    its(:user){ is_expected.to eql user }
  end
end
