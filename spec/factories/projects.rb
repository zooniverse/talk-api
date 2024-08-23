FactoryBot.define do
  factory :project do
    sequence :id
    display_name { "Project #{ id }" }
    slug{ "#{ create(:user).login.parameterize }/#{ display_name.parameterize }" }
    private { nil }
    launch_approved { true }
    sequence :launched_row_order
  end
end
