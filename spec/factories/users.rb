FactoryGirl.define do
  factory :user do
    external_id
    login { "user#{ id }" }
    display_name { "User #{ id }" }
    email { "#{ login }@example.com" }
    admin false
    banned false
    created_at Time.now - 1.year
    valid_email true
    confirmed_at Time.now - 364.days

    factory :moderator do
      transient do
        section 'project-1'
      end

      after :create do |user, evaluator|
        user.roles.create section: evaluator.section, name: 'moderator'
      end
    end

    factory :admin do
      transient do
        section 'project-1'
      end

      after :create do |user, evaluator|
        user.roles.create section: evaluator.section, name: 'admin'
      end
    end

    factory :scientist do
      transient do
        section 'project-1'
      end

      after :create do |user, evaluator|
        user.roles.create section: evaluator.section, name: 'scientist'
      end
    end

    factory :translator do
      transient do
        section 'project-1'
      end

      after :create do |user, evaluator|
        user.roles.create section: evaluator.section, name: 'translator'
      end
    end
  end
end
