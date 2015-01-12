class BoardSchema
  include JSON::SchemaBuilder
  
  root :boards
  
  def create
    root do
      additional_properties false
      string :title,       required: true
      string :description, required: true
      string :section,     required: true
    end
  end
  
  def update
    root do
      additional_properties false
      string :title
      string :description
    end
  end
end
