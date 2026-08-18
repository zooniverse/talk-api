# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  config.after do
    Rack::Attack.cache.store.clear
  end
end