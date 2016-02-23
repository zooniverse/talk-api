require 'aws-sdk'
require 'zoo_stream'

publisher = ZooStream::KinesisPublisher.new(
  stream_name: "zooniverse-#{ Rails.env }",
  client: Aws::Kinesis::Client.new({
    http_open_timeout: 5,
    http_read_timeout: 5
  })
)

ZooStream.publisher = publisher
