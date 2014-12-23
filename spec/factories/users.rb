FactoryGirl.define do
  factory :user do
    external_id
    login { "user#{ id }" }
    email { "#{ login }@example.com" }
  end
end
