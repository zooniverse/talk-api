class BoardSchema
  include JSON::SchemaBuilder
  
  root :boards
  
  def create
    root do
      additional_properties false
      string  :title,       required: true
      string  :description, required: true
      string  :section,     required: true
      entity  :parent_id do
        one_of integer, null
      end
    end
  end
  
  def update
    root do
      additional_properties false
      string :title
      string :description
      entity :parent_id do
        one_of integer, null
      end
    end
  end
end
