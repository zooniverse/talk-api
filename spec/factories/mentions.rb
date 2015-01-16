FactoryGirl.define do
  factory :mention do
    comment
    user
    association :mentionable, factory: :focus
  end
end
