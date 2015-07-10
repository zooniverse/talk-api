FactoryGirl.define do
  factory :moderation do
    association :target, factory: :comment
    section 'project-1'
    
    trait(:opened){ state 0 }
    trait(:ignored){ state 1 }
    trait(:closed){ state 2 }
    trait(:watched){ state 3 }
    
    factory :reported_comment do
      transient do
        message 'reported'
        user nil
      end
      
      before :create do |moderation, evaluator|
        user = evaluator.user || create(:user)
        moderation.reports += [{ message: evaluator.message, user_id: user.id }]
      end
    end
  end
end
