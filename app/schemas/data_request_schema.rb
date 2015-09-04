class DataRequestSchema
  include JSON::SchemaBuilder
  
  root :data_requests
  
  def create
    root do
      additional_properties false
      id :user_id, required: true
      string :section, required: true
      string :kind, required: true do
        enum DataRequest.kinds.keys
      end
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
    end
  end
end
