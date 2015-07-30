FactoryGirl.define do
  factory :notification do
    user
    message 'testing'
    url 'http://www.example.com'
    section 'project-1'
    subscription
  end
end
