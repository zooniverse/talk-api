FactoryGirl.define do
  factory :comment do
    body 'A comment'
    section 'project-1'
    user
    discussion
    user_ip '127.0.0.1'

    factory :comment_for_focus do
      association :focus, factory: :subject
    end
  end
end
