class DiscussionSubscriptionWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(discussion_id)
    discussion = ::Discussion.find discussion_id
    discussion.notify_subscribers
  end
end
