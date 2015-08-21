require 'spec_helper'

RSpec.describe UnsubscribeTokenExpiryWorker, type: :worker do
  it_behaves_like 'an expiry worker', model: UnsubscribeToken
end
