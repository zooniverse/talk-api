FactoryBot.define do
  factory :mention do
    comment
    user
    association :mentionable, factory: :subject
  end
end
