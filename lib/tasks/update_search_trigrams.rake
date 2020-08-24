namespace :search do

  def rkey(resource)
    "rake-task-update-#{resource}-tsvectors"
  end

  def start_id(resource)
    start_batch = if redis.exists(rkey(resource))
      redis.get(rkey(resource))
    else
      # Returns either the arg or the default, 0
      args[:start].to_i
    end
    start_batch
  end

  desc 'Update comment tsvectors'
  task :update_comment_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000)
    redis = Redis.new(host: ENV['REDIS_URL'], db: 15)

    Comment.find_in_batches(start: start_id('comment'), batch_size: args[:batch_size].to_i).with_index do |comments, batch|
      puts "Processing comment group ##{batch}, starting on id #{comments.first.id}"
      comments.map { |comm| comm.searchable.set_content }
      redis.set(rkey('comment'), comments.last.id, ex: 2629746)
      sleep(0.01) # throttle
    end
  end

  desc 'Update discussion tsvectors'
  task :update_discussion_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000)
    redis = Redis.new(host: ENV['REDIS_URL'], db: 15)

    Discussion.find_in_batches(start: start_id('disc'), batch_size: args[:batch_size].to_i).with_index do |discussions, batch|
      puts "Processing discussion group ##{batch}, starting on id #{discussions.first.id}"
      discussions.map { |disc| disc.searchable.set_content }
      redis.set(rkey('disc'), discussions.last.id, ex: 2629746)
      sleep(0.01) # throttle
    end
  end

  desc 'Update board tsvectors'
  task :update_board_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000)
    redis = Redis.new(host: ENV['REDIS_URL'], db: 15)

    Board.find_in_batches(start: start_id('board'), batch_size: args[:batch_size].to_i).with_index do |boards, batch|
      puts "Processing board group ##{batch}, starting on id #{boards.first.id}"
      boards.map { |board| board.searchable.set_content }
      redis.set(rkey('board'), boards.last.id, ex: 2629746)
      sleep(0.01) # throttle
    end
  end
end
