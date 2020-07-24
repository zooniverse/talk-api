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
    MarkdownApi.instance_variable_set :@host, nil
  end

  describe '.config' do
    before(:each){ clear_config }

    it 'should use the env value' do
      expect(MarkdownApi.host).to eql 'http://markdown.localhost'
    end

    context 'with no configuration' do
      it 'should be the default host' do
        ENV.delete 'MARKDOWN_HOST'
        expect(MarkdownApi.host).to eql 'http://markdown.localhost:2998'
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
