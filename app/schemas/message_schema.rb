class MessageSchema
  include JSON::SchemaBuilder

  root :messages

  def create
    root do
      additional_properties false
      entity  :user_id, required: true  do
        one_of string, integer
      end
      entity  :conversation_id, required: true  do
        one_of string, integer
      end
      string :body, required: true
    end
  end
end
