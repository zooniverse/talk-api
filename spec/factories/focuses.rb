FactoryGirl.define do
  factory :focus do
    external_id
    name { "focus_#{ id }" }
    
    factory :subject, class: Subject do
      
    end
    
    factory :collection, class: Collection do
      user
    end
  end
end
