require 'spec_helper'

RSpec.describe MarkdownApi, type: :lib do
  subject{ MarkdownApi }

  before(:each){ reset_config }
  after(:each){ reset_config }

  def reset_config
    ENV['MARKDOWN_HOST'] = 'http://markdown.localhost'
    clear_config
  end

  def clear_config
    ENV.delete 'MARKDOWN_HOST'
    MarkdownApi.instance_variable_set :@host, nil
  end

  describe '.config' do
    before(:each){ clear_config }
    let(:yaml_config) do
      {
        'host' => 'yaml_host'
      }
    end

    def stub_config_file(exists: true)
      double.tap do |stubbed|
        expect(Rails.root).to receive(:join).with('config/markdown.yml').and_return stubbed
        expect(stubbed).to receive(:exist?).and_return exists
      end
    end

    def stub_yaml_config(config_file)
      expect(config_file).to receive :read
      expect(YAML).to receive(:load).and_return 'test' => yaml_config
    end

    def stub_missing_config(config_file)
      expect(config_file).to_not receive :read
      expect(YAML).to_not receive :load
    end

    context 'with YAML configuration' do
      it 'should load config/markdown.yml' do
        stub_yaml_config stub_config_file
        expect(MarkdownApi.host).to eql yaml_config['host']
      end
    end

    context 'with ENV configuration' do
      before(:each){ ENV['MARKDOWN_HOST'] = 'some_host' }

      it 'should not load missing config' do
        stub_missing_config stub_config_file exists: false
        expect(MarkdownApi.host).to eql 'some_host'
      end

      it 'should prioritize ENV over YAML' do
        stub_yaml_config stub_config_file
        expect(MarkdownApi.host).to eql 'some_host'
      end
    end

    context 'with no configuration' do
      it 'should not set the host' do
        stub_missing_config stub_config_file exists: false
        expect(MarkdownApi.host).to be nil
      end
    end
  end

  describe '.markdown' do
    let(:body){ '**test** _markdown_' }
    let(:slug){ 'foo/bar' }
    let!(:stubbed_request) do
      stub_request(:post, 'http://markdown.localhost/html')
        .with body: { markdown: body, project: slug }.to_json, headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'text/html'
        }
    end

    it 'should set request headers' do
      MarkdownApi.markdown body, slug: slug
      expect(stubbed_request).to have_been_requested.once
    end
  end
end
