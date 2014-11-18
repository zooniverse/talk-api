FactoryGirl.define do
  trait :external_id do
    transient do
      sequence :external_id
    end
    
    id { external_id }
  end
end
