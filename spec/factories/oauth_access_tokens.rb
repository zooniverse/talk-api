FactoryBot.define do
  factory :oauth_access_token do
    sequence :id
    association :resource_owner, factory: :user
    token { SecureRandom.hex 32 }
    refresh_token { SecureRandom.hex 32 }
    expires_in { 7200 }

    trait :expired do
      created_at { Time.now.utc - expires_in.seconds }
    end

    trait :revoked do
      revoked_at { 1.minute.ago.utc }
    end
  end
end
