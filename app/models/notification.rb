class Notification < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :subscription, required: true
  scope :expired, ->{ where 'created_at < ?', 3.months.ago.utc }
  after_create :publish
  validates :url, presence: true
  validates :message, presence: true
  validates :section, presence: true
  
  protected
  
  def publish
    NotificationWorker.perform_async id
  end
end
