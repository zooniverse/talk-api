class MessageSchema
  include JSON::SchemaBuilder
  
  root :messages
  
  def create
    root do
      additional_properties false
      integer :user_id, required: true
      integer :conversation_id, required: true
      string :body, required: true
    end
  end
end
