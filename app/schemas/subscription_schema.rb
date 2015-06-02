class SubscriptionSchema
  include JSON::SchemaBuilder
  
  root :subscriptions
  
  def update
    root do
      additional_properties false
      boolean :enabled, required: true
    end
  end
end
