require 'faraday'
require 'faraday_middleware'

class MarkdownApi
  def self.host
    return @host if @host
    config_file = Rails.root.join 'config/markdown.yml'
    config = YAML.load(config_file.read)[Rails.env] if config_file.exist?

    @host = if ENV['MARKDOWN_PORT_2998_TCP_ADDR']
      "http://#{ ENV['MARKDOWN_PORT_2998_TCP_ADDR'] }:2998"
    else
      ENV['MARKDOWN_HOST'] || config.try(:[], 'host')
    end
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
