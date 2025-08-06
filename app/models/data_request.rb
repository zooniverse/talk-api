class DataRequest < ApplicationRecord
  include Sectioned
  include Subscribable
  include Notifiable
  include Expirable

  belongs_to :user, required: true
  validates :section, presence: true
  validates :kind, presence: true,
    uniqueness: { scope: [:section, :user_id], message: 'has already been created' },
    inclusion: { in: %w(tags comments), message: 'must be "tags" or "comments"' }

  before_create :set_expiration
  after_commit :spawn_worker, on: :create

  enum state: {
    pending: 0,
    started: 1,
    finished: 2,
    failed: 3
  }

  def self.kinds
    {
      tags: TagExportWorker,
      votable_tags: VotableTagExportWorker,
      comments: CommentExportWorker
    }
  end

  def notify_user(notification)
    subscription = user.subscribe_to self, :system

    Notification.create(notification.merge({
      source: self,
      user_id: user.id,
      section: section,
      subscription: subscription
    })) if subscription.try(:enabled?)
  end

  def worker
    self.class.kinds[self.kind.to_sym]
  end

  def set_expiration
    self.expires_at = 1.day.from_now.utc
  end

  def spawn_worker
    worker.perform_async id
  end
end
