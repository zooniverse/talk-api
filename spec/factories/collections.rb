FactoryGirl.define do
  factory :collection do
    sequence :id
    name{ "collection_#{ id }" }
    display_name{ "Collection #{ id }" }
    slug{ "#{ create(:user).login.parameterize }/#{ display_name.parameterize }" }
    project
  end
end
