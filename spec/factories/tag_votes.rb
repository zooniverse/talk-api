FactoryBot.define do
  factory :tag_vote do
    user_id { 1 }
    votable_tag { nil }
  end
end