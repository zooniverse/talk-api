FactoryBot.define do
  factory :blocked_user do
    user
    association :blocked_user, factory: :user
  end
end
