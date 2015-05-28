class Subscription < ActiveRecord::Base
  include SubscriptionCategories
  belongs_to :user, required: true
  belongs_to :source, polymorphic: true, required: true
  
  before_create :ensure_enabled
  
  def preference
    @preference ||= SubscriptionPreference.find_or_default_for(user, category)
  end
  
  def ensure_enabled
    preference.enabled?
  end
end
