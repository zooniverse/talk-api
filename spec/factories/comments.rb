FactoryGirl.define do
  factory :comment do
    body 'A comment'
    user
    discussion
    
    factory :comment_for_focus do
      focus
    end
  end
end
