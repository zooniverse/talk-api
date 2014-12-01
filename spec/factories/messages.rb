FactoryGirl.define do
  factory :message do
    association :sender, factory: :user
    association :recipient, factory: :user
    conversation
    body{ "Message from #{ sender.name } to #{ recipient.name }" }
  end
end
