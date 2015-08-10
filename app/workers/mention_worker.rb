class MentionWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(mention_id)
    mention = ::Mention.find mention_id
    mention.notify_mentioned
  end
end
