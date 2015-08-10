class CommentSubscriptionWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(comment_id)
    comment = ::Comment.find comment_id
    comment.notify_subscribers
  end
end
