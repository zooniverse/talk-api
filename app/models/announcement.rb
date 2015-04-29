class Announcement < ActiveRecord::Base
  before_create :assign_default_expiration
  
  protected
  
  def assign_default_expiration
    self.expires_at ||= 1.month.from_now.utc
  end
end
