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
      object  :permissions, required: true do
        string :read, required: true
        string :write, required: true
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
      object :permissions do
        string :read, required: true
        string :write, required: true
      end
    end
  end
end
