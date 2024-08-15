FactoryBot.define do
  factory :subscription do
    category { :participating_discussions }
    user
    association :source, factory: :discussion
  end
end
