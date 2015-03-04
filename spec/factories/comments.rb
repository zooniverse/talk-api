FactoryGirl.define do
  factory :comment do
    body 'A comment'
    section 'test'
    user
    discussion
    
    factory :comment_for_focus do
      association :focus, factory: :subject
    end
  end
end
