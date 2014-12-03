FactoryGirl.define do
  factory :moderation do
    association :target, factory: :comment
    
    trait(:opened){ state 0 }
    trait(:ignored){ state 1 }
    trait(:closed){ state 2 }
    trait(:logged){ state 3 }
    trait(:watched){ state 4 }
  end
end
