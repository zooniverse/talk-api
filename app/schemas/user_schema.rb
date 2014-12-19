class UserSchema
  include JSON::SchemaBuilder
  
  root :users
  
  def update
    root do
      additional_properties false
      object :preferences do
        # TO-DO: Define what preferences are acceptable
        additional_properties true
      end
    end
  end
end
