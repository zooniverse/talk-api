require 'aws-sdk-s3'

class Uploader
  delegate :initialize_s3, to: :class
  class_attribute :bucket, :bucket_path
  attr_accessor :local_file, :remote_file

  def self.initialize_s3
    return if @_configured
    self.bucket = ENV.fetch('AWS_BUCKET', 'a-bucket')
    self.bucket_path = ENV.fetch('AWS_BUCKET_PATH', 'a/bucket/path')
    @_configured = true
  end

  def initialize(file)
    initialize_s3
    self.local_file = file
    self.remote_file = ::Aws::S3::Object.new bucket_name: bucket, key: upload_path
  end

  def upload
    ::File.open(local_file.path, 'rb') do |stream|
      remote_file.upload_file stream, content_type: mime_type
    end
  end

  def url
    remote_file.presigned_url :get, expires_in: 1.week.in_seconds
  end

  def mime_type
    `file --brief --mime #{ local_file.path }`.chomp.split(';').first
  rescue
    'text/plain'
  end

  def upload_path
    "#{ bucket_path }/#{ ::File.basename local_file }".gsub /\/{2,}/, '/'
  end
end
