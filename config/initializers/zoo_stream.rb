if Rails.env.staging? || Rails.env.production?
  require 'aws-sdk'
  require 'zoo_stream'
  Aws.config.update region: 'us-east-1'
  ZooStream.source = "talk-#{ Rails.env }"
  publisher = ZooStream::KinesisPublisher.new(
    stream_name: "zooniverse-#{ Rails.env }",
    client: Aws::Kinesis::Client.new({
      http_open_timeout: 5,
      http_read_timeout: 5
    })
  )

  ZooStream.publisher = publisher
end
