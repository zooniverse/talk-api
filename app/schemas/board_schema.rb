class BoardSchema
  include JSON::SchemaBuilder
  
  root :boards
  
  def create
    root do |root_object|
      changes root_object, required: true
      string :section, required: true
    end
  end
  
  def update
    root do |root_object|
      changes root_object
    end
  end
  
  def changes(obj, required = { })
    obj.additional_properties false
    obj.string :title, **required
    obj.string :description, **required
    obj.boolean :subject_default
    obj.id :parent_id, null: true
    obj.permissions obj, required
  end
  
  def permissions(obj, required = { })
    obj.object :permissions, **required do |permission_object|
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
