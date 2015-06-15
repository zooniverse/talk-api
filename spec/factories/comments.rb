FactoryGirl.define do
  factory :comment do
    body 'A comment'
    section 'project-1'
    user
    discussion
    
    factory :comment_for_focus do
      association :focus, factory: :subject
    end
  end
end
