FactoryGirl.define do
  factory :oauth_access_token do
    sequence :id
    association :resource_owner, factory: :user
    token{ SecureRandom.hex 32 }
    refresh_token{ SecureRandom.hex 32 }
    expires_in 7200
  end
end
