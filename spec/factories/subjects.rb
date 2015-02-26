FactoryGirl.define do
  factory :subject do
    sequence :id
    locations do
      [{
        "image/png" => "panoptes-uploads.zooniverse.org/#{ id }.png"
      }]
    end
    project
  end
end
