class DataRequest < ActiveRecord::Base
  include Subscribable
  
  belongs_to :user, required: true
  validates :section, presence: true
  validates :kind, presence: true,
    uniqueness: { scope: [:section], message: 'has already been created' },
    inclusion: { in: %w(tags comments), message: 'must be "tags" or "comments"' }
  
  before_create :set_expiration
  after_commit :spawn_worker, on: :create
  
  def self.kinds
    {
      tags: TagExportWorker,
      comments: CommentExportWorker
    }
  end
  
  def notify_user(notification)
    subscription = user.subscribe_to self, :system
    
    Notification.create(notification.merge({
      user_id: user.id,
      section: section,
      subscription: subscription
    })) if subscription.try(:enabled?)
  end
  
  def worker
    self.class.kinds[self.kind.to_sym]
  end
  
  def worker_interval
    worker.sidekiq_options['congestion'][:interval]
  end
  
  def set_expiration
    self.expires_at = worker_interval.from_now.utc
  end
  
  def spawn_worker
    worker.perform_async id
  end
end
