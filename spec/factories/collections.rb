FactoryGirl.define do
  factory :collection do
    sequence :id
    name{ "collection_#{ id }" }
    display_name{ "Collection #{ id }" }
    slug{ "#{ create(:user).login.parameterize }/#{ display_name.parameterize }" }

    before :create do |collection, evaluator|
      unless collection.projects.present?
        collection.projects = create_list(:project, 2)
      end
    end
  end
end
