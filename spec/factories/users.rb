FactoryGirl.define do
  factory :user do
    external_id
    login { "user#{ id }" }
  end
end
