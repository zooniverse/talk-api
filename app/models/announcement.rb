class Announcement < ActiveRecord::Base
  include Expirable
  include Sectioned

  before_create :assign_default_expiration
  after_commit :publish, on: :create

  protected

  def assign_default_expiration
    self.expires_at ||= 1.month.from_now.utc
  end

  def publish
    AnnouncementWorker.perform_async id
  end
end
