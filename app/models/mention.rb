class Mention < ActiveRecord::Base
  belongs_to :comment, required: true
  belongs_to :user, required: true
  belongs_to :mentionable, polymorphic: true, required: true
  
  after_commit :notify_later, on: :create
  
  def notify_later
    MentionWorker.perform_async id
  end
  
  def notify_mentioned
    mentionable.mentioned_by comment
  end
end
