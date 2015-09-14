class GroupMentionWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(mention_id)
    mention = ::GroupMention.find mention_id
    mention.notify_mentioned
  end
end
