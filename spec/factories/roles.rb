FactoryGirl.define do
  factory :role do
    user
    name 'admin'
    section 'project-1'
    
    %w(admin moderator scientist team).each do |role_name|
      factory :"#{ role_name }_role" do
        name role_name
      end
    end
  end
end
