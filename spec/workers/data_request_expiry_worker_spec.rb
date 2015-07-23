require 'rspec'

RSpec.describe DataRequestExpiryWorker, type: :worker do
  it_behaves_like 'an expiry worker', model: DataRequest
end