class UserIpBanSchema
  include JSON::SchemaBuilder
  
  root :user_ip_bans
  
  def create
    root do
      additional_properties false
      string :ip, required: true
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
    end
  end
end
