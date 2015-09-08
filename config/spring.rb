Spring.after_fork do
  if Rails.env.test?
    RSpec.configure do |config|
      srand; config.seed = srand % 0xFFFF
    end
  end
end
