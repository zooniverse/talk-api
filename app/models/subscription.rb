class Subscription < ActiveRecord::Base
  include SubscriptionCategories
  
  has_many :notifications, dependent: :destroy
  belongs_to :user, required: true
  belongs_to :source, polymorphic: true, required: true
  
  before_create :ensure_enabled
  after_update :clear_notifications, if: ->{ enabled_change == [true, false] }
  
  def preference
    @preference ||= SubscriptionPreference.find_or_default_for(user, category)
  end
  
  def ensure_enabled
    preference.enabled?
  end
  
  def enabled?
    persisted? && super
  end
  
  def clear_notifications
    notifications.destroy_all
  end
end
