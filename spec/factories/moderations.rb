FactoryGirl.define do
  factory :moderation do
    association :target, factory: :comment
    section 'project-1'
    
    trait(:opened){ state 0 }
    trait(:ignored){ state 1 }
    trait(:closed){ state 2 }
    trait(:watched){ state 3 }
  end
end
