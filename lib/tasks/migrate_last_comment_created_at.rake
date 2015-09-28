namespace :data do
  desc 'sets most recent comment created at timestamp on discussions and boards'
  task migrate_last_comment_created_at: :environment do
    Discussion.find_each do |discussion|
      last_comment_created_at = discussion.comments.order(created_at: :desc).first.try(:created_at) || discussion.created_at
      discussion.update_columns last_comment_created_at: last_comment_created_at
    end
    
    Board.find_each do |board|
      last_comment_created_at = board.discussions.order(last_comment_created_at: :desc).first.try(:created_at) || board.created_at
      board.update_columns last_comment_created_at: last_comment_created_at
    end
  end
end
