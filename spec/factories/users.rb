FactoryGirl.define do
  factory :user do
    external_id
    name { "user#{ id }" }
  end
end
