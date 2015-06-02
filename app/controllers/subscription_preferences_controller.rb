class SubscriptionPreferencesController < ApplicationController
  include TalkResource
  
  before_action :ensure_defaults
  
  def ensure_defaults
    SubscriptionPreference.for_user(current_user) if current_user
  end
end
