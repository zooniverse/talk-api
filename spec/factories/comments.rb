FactoryGirl.define do
  factory :comment do
    body 'A comment'
    user
    
    factory :comment_for_focus do
      focus
    end
  end
end
