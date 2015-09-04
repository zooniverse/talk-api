class NotificationSchema
  include JSON::SchemaBuilder
  
  root :notifications
  
  def create
    root do |root_object|
      additional_properties false
    end
  end
  
  def update
    root do
      additional_properties false
      boolean :delivered, required: true
    end
  end
end
