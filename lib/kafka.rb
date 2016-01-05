require 'yaml'
require 'poseidon'

class Kafka
  def self.config
    @config ||= ::YAML.load(
      ::File.read(::Rails.root.join('config/kafka.yml'))
    )[Rails.env]
  end
  
  def self.producer
    @producer ||= ::Poseidon::Producer.new(
      config['brokers'],
      config['producer_id'],
      socket_timeout_ms: config['timeout']
    )
  end
  
  def self.publish(topic, payload, key)
    message = ::Poseidon::MessageToSend.new topic, payload.to_json, key
    producer.send_messages [message]
  end
end
