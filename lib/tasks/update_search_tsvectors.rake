namespace :search do

  class VectorUpdater
    attr_reader :redis, :start, :batch_size, :resource

    def initialize(args)
      @redis = Redis.new(url: ENV['REDIS_URL'], db: 15)
      @resource = args[:resource]
      @batch_size = args[:batch_size].to_i
      @start = args[:start].to_i
    end

    def start_id
      if redis.exists(rkey)
        redis.get(rkey).to_i
      else
        start
      end
    end

    def rkey
      "rake-task-update-#{resource}-tsvectors"
    end

    def process
      # Test redis connection to raise error if unavailable before processing begins
      redis.ping

      klass = resource.capitalize.constantize
      puts "Processing #{klass}s..."
      klass.find_in_batches(start: start_id, batch_size: batch_size).with_index do |resources, batch|
        puts "Processing batch ##{batch}, starting on id #{resources.first.id}"
        resources.map { |res| res&.searchable.set_content }

        # Checkpoint the id of the last resource in the batch in Redis
        checkpoint_record_id = comments.last.id
        redis.set(rkey, checkpoint_record_id, ex: 2629746)
        sleep(0.01) # throttle
      end
      puts "Processing finished!"
    end
  end

  desc 'Update comment tsvectors'
  task :update_comment_tsvectors, [:start, :batch_size] => :environment do |t, args|
    # Set defaults so there are no nils
    args.with_defaults(start: 0, batch_size: 1000, resource: 'comment')
    processor = VectorUpdater.new(args)
    processor.process
  end

  desc 'Update discussion tsvectors'
  task :update_discussion_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000, resource: 'discussion')
    processor = VectorUpdater.new(args)
    processor.process
  end

  desc 'Update board tsvectors'
  task :update_board_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000, resource: 'board')
    processor = VectorUpdater.new(args)
    processor.process
  end
end
