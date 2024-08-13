FactoryBot.define do
  factory :subscription_preference do
    category { :participating_discussions }
    user
  end
end
