class AnnouncementSchema
  include JSON::SchemaBuilder
  
  root :announcements
  
  def create
    changes required: true
  end
  
  def update
    changes
  end
  
  def changes(required = { })
    root do
      additional_properties false
      string :message, **required
      string :section, **required
      string :expires_at
    end
  end
end
