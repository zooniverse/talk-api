FactoryGirl.define do
  factory :user do
    external_id
    display_name { "user#{ id }" }
    email { "#{ display_name }@example.com" }
    admin false
    banned false
    
    factory :moderator do
      transient do
        section 'test'
      end
      
      after :create do |user, evaluator|
        user.roles.create scope: evaluator.section, name: 'moderator'
      end
    end
    
    factory :admin do
      transient do
        section 'test'
      end
      
      after :create do |user, evaluator|
        user.roles.create scope: evaluator.section, name: 'admin'
      end
    end
    
    factory :scientist do
      transient do
        section 'test'
      end
      
      after :create do |user, evaluator|
        user.roles.create scope: evaluator.section, name: 'scientist'
      end
    end
  end
end
