FactoryGirl.define do
  factory :notification do
    user
    message 'testing'
    url 'http://www.example.com'
    section 'zooniverse'
  end
end
