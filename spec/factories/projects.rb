FactoryGirl.define do
  factory :project do
    sequence :id
    display_name{ "Project #{ id }" }
    slug{ "#{ create(:user).login.parameterize }/#{ display_name.parameterize }" }
  end
end
