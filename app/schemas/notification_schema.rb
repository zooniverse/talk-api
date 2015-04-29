class NotificationSchema
  include JSON::SchemaBuilder
  
  root :notifications
  
  def update
    root do
      additional_properties false
      boolean :delivered, required: true
    end
  end
end
