class MessageSchema
  include JSON::SchemaBuilder
  
  root :messages
  
  def create
    root do
      additional_properties false
      id :user_id, required: true
      id :conversation_id, required: true
      string :body, required: true
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
    end
  end
end
