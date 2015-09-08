class ConversationSchema
  include JSON::SchemaBuilder
  
  root :conversations
  
  def create
    root do
      additional_properties false
      string :title, required: true
      id :user_id, required: true
      string :body, required: true
      
      array :recipient_ids, required: true, unique_items: true, min_items: 1 do
        items type: :id
      end
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
    end
  end
end
