FactoryBot.define do
  factory :user_ip_ban do
    ip { '1.2.3.4/24' }
  end
end
