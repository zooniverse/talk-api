class BlockedUserSchema
  include JSON::SchemaBuilder
  
  root :blocked_users
  
  def create
    root do |root_object|
      additional_properties false
      id :user_id, required: true
      id :blocked_user_id, required: true
    end
  end
end
