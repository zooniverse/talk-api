FactoryGirl.define do
  factory :subject do
    sequence :id
    project
    after(:create) do |subject|
      create_list :medium, 2, linked: subject
    end
  end
end
