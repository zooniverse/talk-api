class MessageSchema
  include JSON::SchemaBuilder
  
  root :messages
  
  def create
    root do
      integer :user_id, required: true
      integer :conversation_id, required: true
      string :body, required: true
    end
  end
end
