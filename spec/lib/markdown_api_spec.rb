require 'spec_helper'

RSpec.describe MarkdownApi, type: :lib do
  subject{ MarkdownApi }

  describe '.config' do
    it 'should use the env value' do
      ENV['MARKDOWN_HOST'] = 'http://markdown.localhost'
      expect(MarkdownApi.host).to eql 'http://markdown.localhost'
      ENV.delete 'MARKDOWN_HOST'
    end

    context 'with no configuration' do
      it 'should be the default host' do
        expect(MarkdownApi.host).to eql 'http://markdown.localhost:2998'
      end
    end
  end

  describe '.markdown' do
    let(:body){ '**test** _markdown_' }
    let(:slug){ 'foo/bar' }
    let!(:stubbed_request) do
      stub_request(:post, 'http://markdown.localhost:2998/html')
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
