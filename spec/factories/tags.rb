FactoryGirl.define do
  factory :tag do
    name{ "tag#{ id }" }
    section 'test'
  end

end
