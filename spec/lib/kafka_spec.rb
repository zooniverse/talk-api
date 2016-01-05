require 'spec_helper'

RSpec.describe Kafka, type: :lib do
  subject{ Kafka }
  let(:config) do
    {
      'producer_id' => 'foo',
      'brokers' => ['broker1', 'broker2'],
      'timeout' => 12345
    }
  end
  
  before(:each) do
    path = Rails.root.join 'config/kafka.yml'
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(path).and_return({ 'test' => config }.to_yaml)
    
    Kafka.class_eval do
      @config = nil
      @producer = nil
    end
  end
  
  its(:config){ is_expected.to eql config }
  
  describe '.producer' do
    it 'should initialize a producer' do
      expect(Poseidon::Producer).to receive(:new).with ['broker1', 'broker2'],
        'foo', socket_timeout_ms: kind_of(Fixnum)
      Kafka.producer
    end
    
    it 'should memoize the producer' do
      expect(Kafka.producer.object_id).to eql Kafka.producer.object_id
    end
  end
  
  describe '.publish' do
    it 'should create a message' do
      allow(Kafka.producer).to receive :send_messages
      expect(Poseidon::MessageToSend).to receive(:new).with 'topic', '"payload"', 'key'
      Kafka.publish 'topic', 'payload', 'key'
    end
    
    it 'should send the message' do
      message_double = double
      allow(Poseidon::MessageToSend).to receive(:new).and_return message_double
      expect(Kafka.producer).to receive(:send_messages).with [message_double]
      Kafka.publish 'topic', 'payload', 'key'
    end
  end
end
