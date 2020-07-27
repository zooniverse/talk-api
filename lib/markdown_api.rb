require 'faraday'
require 'faraday_middleware'

class MarkdownApi
  def self.host
    ENV.fetch('MARKDOWN_HOST', 'http://markdown.localhost:2998')
  end

  def self.connection
    @connection ||= Faraday.new "#{ host }" do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  def self.request(method, path, *args)
    connection.send(method, path, *args) do |req|
      req.headers['Accept'] = 'text/html'
      req.headers['Content-Type'] = 'application/json'
      yield req if block_given?
    end
  rescue URI::BadURIError => e
    ::Rails.logger.warn 'MarkdownApi configuration is not valid'
  end

  def self.markdown(text, slug: nil)
    request(:post, '/html', { markdown: text, project: slug }.to_json).body.force_encoding Encoding::UTF_8
  rescue => e
    Talk.report_error e
    text
  end
end
