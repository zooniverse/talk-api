module DataExportWorker
  extend ::ActiveSupport::Concern
  
  included do
    include Sidekiq::Worker
    class << self
      attr_accessor :name
    end
    attr_accessor :section, :name
    
    sidekiq_options retry: false, backtrace: true, congestion: {
      interval: 1.day,
      max_in_interval: 1,
      min_delay: 1.day,
      reject_with: :cancel
    }
  end
  
  def perform(section)
    self.section = section
    self.name = "#{ section }-#{ self.class.name }_#{ Time.now.utc.to_date.to_s }"
    process_data
  end
  
  def process_data
    data_file = write_data
    gzip_file = compress data_file
    ::File.unlink data_file
    # TO-DO:
    #   upload
    #   generate pre-signed key
    #   email link
    `cp #{ gzip_file.path } ./`
    ::File.unlink gzip_file
  end
  
  def row_from(*args)
    args.as_json
  end
  
  def find_each
    raise NotImplementedError.new 'find_each'
  end
  
  def each_row
    index = 0
    find_each do |*args|
      yield row_from(*args), index
      index += 1
    end
  end
  
  def write_data
    ::File.open("#{ name }.json", 'w').tap do |file|
      file.write '['
      each_row do |row, index|
        file.write(',') unless index.zero?
        file.write row.to_json
      end
      file.write "]\n"
      file.close
    end
  end
  
  def compress(in_file)
    out_file = "/tmp/#{ name }.tar.gz"
    in_name = ::File.basename in_file.path
    in_path = ::File.dirname in_file.path
    `cd #{ in_path } && tar czf #{ out_file } #{ in_name }`
    ::File.new out_file
  end
end
