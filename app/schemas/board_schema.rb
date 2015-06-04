class BoardSchema
  include JSON::SchemaBuilder
  
  root :boards
  
  def create
    root do |root_object|
      additional_properties false
      string  :title,       required: true
      string  :description, required: true
      string  :section,     required: true
      entity  :parent_id do
        one_of integer, null
      end
      permissions root_object, required: true
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
      string :title
      string :description
      entity :parent_id do
        one_of integer, null
      end
      permissions root_object
    end
  end
  
  def permissions(obj, required: false)
    obj.required << :permissions if required
    obj.object :permissions do |permission_object|
      permission permission_object, :read
      permission permission_object, :write
    end
  end
  
  def permission(obj, name)
    obj.entity name, required: true do
      enum [:all, :team, :moderator, :admin]
    end
  end
end
