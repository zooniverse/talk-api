FactoryBot.define do
  factory :data_request do
    user factory: :admin
    section { 'project-1' }
    kind { 'comments' }

    factory :tags_data_request do
      kind { 'tags' }
    end

    factory :votable_tags_data_request do
      kind { 'votable_tags' }
    end

    factory :comments_data_request do
      kind { 'comments' }
    end
  end
end
