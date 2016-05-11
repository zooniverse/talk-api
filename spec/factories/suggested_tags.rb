FactoryGirl.define do
  factory :suggested_tag do
    name{ "suggested-tag#{ id }" }
    section 'project-1'
  end
end
