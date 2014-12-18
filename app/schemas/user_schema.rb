class UserSchema
  include JSON::SchemaBuilder
  
  root :users
  
  def update
    root do
      object :preferences do
        # TO-DO: Define what preferences are acceptable
        additional_properties true
      end
    end
  end
end
