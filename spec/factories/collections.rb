FactoryGirl.define do
  factory :collection do
    sequence :id
    name{ "collection_#{ id }" }
    display_name{ "Collection #{ id }" }
    project
  end
end
