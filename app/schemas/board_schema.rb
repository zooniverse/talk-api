class BoardSchema
  include JSON::SchemaBuilder
  configure{ |opts| opts.strict = true }
  
  root :boards
  
  def create
    root do
      string :title,       required: true
      string :description, required: true
      string :section
    end
  end
  
  def update
    root do
      string :title,       required: true
      string :description, required: true
    end
  end
end
