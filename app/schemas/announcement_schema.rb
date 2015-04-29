class AnnouncementSchema
  include JSON::SchemaBuilder
  
  root :announcements
  
  def create
    root do
      additional_properties false
      string  :message,    required: true
      string  :section,    required: true
      string  :expires_at
    end
  end
  
  def update
    root do
      additional_properties false
      string  :message
      string  :section
      string  :expires_at
    end
  end
end
