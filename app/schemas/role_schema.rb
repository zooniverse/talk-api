class RoleSchema
  include JSON::SchemaBuilder

  root :roles

  def create
    root do |root_object|
      additional_properties false
      entity  :user_id, required: true  do
        one_of string, integer
      end
      string  :section, required: true
      boolean :is_shown, default: true
      role_names root_object
    end
  end

  def update
    root do |root_object|
      additional_properties false
      role_names root_object
      boolean :is_shown, default: true
    end
  end

  def role_names(obj)
    obj.string :name, required: true do
      enum [:admin, :moderator, :scientist, :team]
    end
  end
end
