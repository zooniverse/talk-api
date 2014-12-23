require 'spec_helper'

RSpec.describe PanoptesProxy, type: :lib do
  before(:each){ ENV['PANOPTES_HOST'] = 'http://panoptes.localhost' }
  let(:proxy){ PanoptesProxy.new 'bearer_token' }
  
  def clear_host
    ENV.delete 'PANOPTES_HOST'
    PanoptesProxy.instance_variable_set :@host, nil
  end
  
  describe '.host' do
    before(:each){ clear_host }
    
    def stub_config_file(exists: true)
      double.tap do |stubbed|
        expect(Rails.root).to receive(:join).with('config/panoptes.yml').and_return stubbed
        expect(stubbed).to receive(:exist?).and_return exists
      end
    end
    
    def stub_yaml_config(config_file)
      expect(config_file).to receive :read
      expect(YAML).to receive(:load).and_return 'test' => { 'host' => 'yaml_host' }
    end
    
    def stub_missing_config(config_file)
      expect(config_file).to_not receive :read
      expect(YAML).to_not receive :load
    end
    
    context 'with YAML configuration' do
      it 'should load config/panoptes.yml' do
        stub_yaml_config stub_config_file
        expect(PanoptesProxy.host).to eql 'yaml_host'
      end
    end
    
    context 'with ENV configuration' do
      before(:each){ ENV['PANOPTES_HOST'] = 'some_host' }
      
      it 'should not load missing config' do
        stub_missing_config stub_config_file exists: false
        expect(PanoptesProxy.host).to eql 'some_host'
      end
      
      it 'should prioritize ENV over YAML' do
        stub_yaml_config stub_config_file
        expect(PanoptesProxy.host).to eql 'some_host'
      end
    end
    
    context 'with no configuration' do
      it 'should not set the host' do
        stub_missing_config stub_config_file exists: false
        expect(PanoptesProxy.host).to be nil
      end
    end
  end
  
  describe '#initialize' do
    subject{ proxy }
    its(:token){ is_expected.to eql 'bearer_token' }
    
    describe 'connection' do
      subject{ proxy.connection }
      it{ is_expected.to be_a Faraday::Connection }
      its(:url_prefix){ is_expected.to eql URI '/some_host/api' }
    end
  end
  
  describe '#normalize' do
    it 'should not strip normalized paths' do
      expect(proxy.normalize('some/path')).to eql 'some/path'
    end
    
    it 'should strip /api' do
      expect(proxy.normalize('/api/path')).to eql 'path'
    end
    
    it 'should strip /' do
      expect(proxy.normalize('/path')).to eql 'path'
    end
    
    it 'should preserve path' do
      expect(proxy.normalize('/some/api/path')).to eql 'some/api/path'
    end
  end
  
  %w(get put post delete).each do |method|
    describe "##{ method }" do
      it "should send #{ method } requests" do
        expect(subject).to receive(:request).with method, 'path', 1, 2, 3
        subject.send method, 'path', 1, 2, 3
      end
    end
  end
  
  describe '#request' do
    it 'send requests' do
      expect(proxy.connection).to receive(:send).with 'get', 'path', 'argument'
      proxy.get 'path', 'argument'
    end
    
    it 'should yield to a block' do
      block_called = false
      stub_request :get, 'http://panoptes.localhost/api/path'
      proxy.request(:get, 'path'){ block_called = true }
      expect(block_called).to be true
    end
    
    it 'should set accept header' do
      stub_request :get, 'http://panoptes.localhost/api/path'
      proxy.request(:get, 'path') do |req|
        expect(req.headers['Accept']).to eql 'application/vnd.api+json; version=1'
      end
    end
    
    it 'should set content-type header' do
      stub_request :get, 'http://panoptes.localhost/api/path'
      proxy.request(:get, 'path') do |req|
        expect(req.headers['Content-Type']).to eql 'application/json'
      end
    end
    
    context 'with a token' do
      it 'should set authorization header' do
        stub_request :get, 'http://panoptes.localhost/api/path'
        proxy.request(:get, 'path') do |req|
          expect(req.headers['Authorization']).to eql 'Bearer bearer_token'
        end
      end
    end
    
    context 'without a token' do
      it 'should not set authorization header' do
        stub_request :get, 'http://panoptes.localhost/api/path'
        PanoptesProxy.new.request(:get, 'path') do |req|
          expect(req.headers).to_not have_key 'Authorization'
        end
      end
    end
  end
end
