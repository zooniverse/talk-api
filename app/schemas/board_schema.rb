class BoardSchema
  include JSON::SchemaBuilder
  configure{ |opts| opts.strict = true }
  
  root :boards
  
  def create
    root do
      additional_properties false
      string :title,       required: true
      string :description, required: true
      string :section
    end
  end
  
  def update
    root do
      additional_properties false
      string :title,       required: true
      string :description, required: true
    end
  end
end
