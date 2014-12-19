class ConversationSchema
  include JSON::SchemaBuilder
  
  root :conversations
  
  def create
    root do
      additional_properties false
      string  :title,   required: true
      integer :user_id, required: true
      string  :body,    required: true
      
      array :recipient_ids, required: true, unique_items: true, min_items: 1 do
        items type: :integer
      end
    end
  end
end
