namespace :search do

  desc 'Update comment trigrams'
  task update_comment_trigrams: :environment do
    Comment.find_in_batches.with_index do |comments, batch|
      puts "Processing comment group ##{batch}"
      comments.map { |comm| comm.searchable.set_content }
      sleep(0.01) # throttle
    end
  end

  desc 'Update discussion trigrams'
  task update_discussion_trigrams: :environment do
    Discussion.find_in_batches.with_index do |discussions, batch|
      puts "Processing discussion group ##{batch}"
      discussions.map { |disc| disc.searchable.set_content }
      sleep(0.01) # throttle
    end
  end

  desc 'Update board trigrams'
  task update_boards_trigrams: :environment do
    Board.find_in_batches.with_index do |boards, batch|
      puts "Processing comment group ##{batch}"
      boards.map { |board| board.searchable.set_content }
      sleep(0.01) # throttle
    end
  end
end
