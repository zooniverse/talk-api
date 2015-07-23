require 'spec_helper'

RSpec.describe NotificationExpiryWorker, type: :worker do
  it_behaves_like 'an expiry worker', model: Notification
end
