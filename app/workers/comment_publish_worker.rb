class CommentPublishWorker
  include Sidekiq::Worker

  sidekiq_options retry: true, backtrace: true

  def perform(comment_id)
    comment = ::Comment.find comment_id
    comment.publish_to_event_stream
  end
end
