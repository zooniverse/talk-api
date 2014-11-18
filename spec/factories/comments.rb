FactoryGirl.define do
  factory :comment do
    body 'A comment'
    user
  end
end
