namespace :search do

  desc 'Update comment tsvectors'
  task :update_comment_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000)
    Comment.find_in_batches(start: args[:start].to_i, batch_size: args[:batch_size].to_i).with_index do |comments, batch|
      puts "Processing comment group ##{batch}"
      comments.map { |comm| comm.searchable.set_content }
      sleep(0.01) # throttle
    end
  end

  desc 'Update discussion tsvectors'
  task :update_discussion_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000)
    Discussion.find_in_batches(start: args[:start].to_i, batch_size: args[:batch_size].to_i).with_index do |discussions, batch|
      puts "Processing discussion group ##{batch}"
      discussions.map { |disc| disc.searchable.set_content }
      sleep(0.01) # throttle
    end
  end

  desc 'Update board tsvectors'
  task :update_board_tsvectors, [:start, :batch_size] => :environment do |t, args|
    args.with_defaults(start: 0, batch_size: 1000)
    Board.find_in_batches(start: args[:start].to_i, batch_size: args[:batch_size].to_i).with_index do |boards, batch|
      puts "Processing board group ##{batch}"
      boards.map { |board| board.searchable.set_content }
      sleep(0.01) # throttle
    end
  end
end
