namespace :search do

  desc 'Update comment tsvectors'
  task update_comment_tsvectors: :environment do
    Comment.find_in_batches.with_index do |comments, batch|
      puts "Processing comment group ##{batch}"
      comments.map { |comm| comm.searchable.set_content }
      sleep(0.01) # throttle
    end
  end

  desc 'Update discussion tsvectors'
  task update_discussion_tsvectors: :environment do
    Discussion.find_in_batches.with_index do |discussions, batch|
      puts "Processing discussion group ##{batch}"
      discussions.map { |disc| disc.searchable.set_content }
      sleep(0.01) # throttle
    end
  end

  desc 'Update board tsvectors'
  task update_boards_tsvectors: :environment do
    Board.find_in_batches.with_index do |boards, batch|
      puts "Processing comment group ##{batch}"
      boards.map { |board| board.searchable.set_content }
      sleep(0.01) # throttle
    end
  end
end
