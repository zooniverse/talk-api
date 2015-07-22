class DataRequestSchema
  include JSON::SchemaBuilder
  
  root :data_requests
  
  def create
    root do
      additional_properties false
      entity :user_id, required: true  do
        one_of string, integer
      end
      string :section, required: true
      string :kind,    required: true do
        enum DataRequest.kinds.keys
      end
    end
  end
end
