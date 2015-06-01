class SubscriptionPreferenceSchema
  include JSON::SchemaBuilder
  
  root :subscription_preferences
  
  def update
    root do
      additional_properties false
      boolean :enabled
      string :email_digest do
        enum SubscriptionPreference.email_digests.keys
      end
    end
  end
end
