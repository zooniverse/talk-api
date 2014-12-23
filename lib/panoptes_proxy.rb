require 'faraday'
require 'faraday_middleware'

class PanoptesProxy
  attr_accessor :connection, :token
  
  def self.host
    return @host if @host
    config_file = Rails.root.join 'config/panoptes.yml'
    config = YAML.load(config_file.read)[Rails.env] if config_file.exist?
    @host = ENV['PANOPTES_HOST'] || config.try(:[], 'host')
  end
  
  def initialize(token = nil)
    @token = token
    @connection = Faraday.new "#{ self.class.host }/api" do |faraday|
      faraday.response :json, content_type: /\bjson$/
      faraday.use :http_cache, store: Rails.cache, logger: Rails.logger
      faraday.adapter Faraday.default_adapter
    end
  end
  
  def request(method, path, *args)
    @connection.send(method, normalize(path), *args) do |req|
      req.headers['Accept'] = 'application/vnd.api+json; version=1'
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{ token }" if token
      yield req if block_given?
    end
  end
  
  def normalize(path)
    path.sub /^\/?(\/?api\/?)?/i, ''
  end
  
  %w(get put post delete).each do |method|
    define_method method do |path, *args|
      request method, path, *args
    end
  end
end
