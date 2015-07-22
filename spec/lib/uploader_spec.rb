require 'spec_helper'

RSpec.describe Uploader, type: :lib do
  let(:file){ File.new Rails.root.join('spec/support/image.png') }
  let(:uploader){ Uploader.new file }
  subject{ uploader }
  
  before(:each) do
    Uploader.instance_variable_set :@_configured, nil
    Uploader.bucket = Uploader.bucket_path = nil
    allow(YAML).to receive(:load_file).and_return 'test' => {
      'region' => 'us-east-1',
      'bucket' => 'a-bucket',
      'bucket_path' => 'a/bucket/path'
    }
  end
  
  describe '.initialize_s3' do
    it 'should memoize the s3 config' do
      expect(YAML).to receive(:load_file).once.and_call_original
      2.times{ Uploader.initialize_s3 }
    end
    
    it 'should set the bucket' do
      expect{
        Uploader.initialize_s3
      }.to change {
        Uploader.bucket
      }.from(nil).to 'a-bucket'
    end
    
    it 'should set the bucket_path' do
      expect{
        Uploader.initialize_s3
      }.to change {
        Uploader.bucket_path
      }.from(nil).to 'a/bucket/path'
    end
    
    it 'should configure AWS' do
      expect(Aws.config).to receive(:update).with 'region' => 'us-east-1'
      Uploader.initialize_s3
    end
  end
  
  describe '#initialize' do
    it 'should initialize s3' do
      expect(Uploader).to receive(:initialize_s3)
      subject
    end
    
    its(:local_file){ is_expected.to eql file }
    
    describe '#remote_file' do
      subject{ uploader.remote_file }
      its(:bucket_name){ is_expected.to eql 'a-bucket' }
      its(:key){ is_expected.to eql 'a/bucket/path/image.png' }
    end
  end
  
  describe '#upload' do
    let(:output){ double }
    before(:each) do
      allow(File).to receive(:open).and_yield output
      allow(subject.remote_file).to receive(:upload_file)
    end
    
    it 'should read the input file' do
      expect(File).to receive(:open).with(file.path, 'rb').and_yield output
      subject.upload
    end
    
    it 'should upload the input file' do
      expect(subject).to receive(:mime_type).and_return 'foo/bar'
      expect(subject.remote_file).to receive(:upload_file).with output, content_type: 'foo/bar'
      subject.upload
    end
  end
  
  describe '#url' do
    it 'should generate a presigned url' do
      expect(subject.remote_file).to receive(:presigned_url).with :get, expires_in: a_kind_of(Fixnum)
      subject.url
    end
  end
  
  describe '#mime_type' do
    it 'should find the mime type of a file' do
      expect(subject).to receive(:'`').with("file --brief --mime #{ file.path }").and_call_original
      expect(subject.mime_type).to eql 'image/png'
    end
    
    it 'should handle exceptions' do
      allow(subject).to receive(:'`').and_raise 'hell'
      expect(subject.mime_type).to eql 'text/plain'
    end
  end
end
