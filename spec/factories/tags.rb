FactoryGirl.define do
  factory :tag do
    name{ "tag#{ id }" }
    section 'test'
    user
    comment
    association :taggable, factory: :subject
  end
end
