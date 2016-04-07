class SubscriptionSchema
  include JSON::SchemaBuilder

  root :subscriptions

  # Currently creation is only allowed for
  # Discussion -> followed_discussions
  def create
    root do
      additional_properties false
      id :user_id, required: true
      id :source_id, required: true
      string :source_type, required: true do
        enum %w(Board Discussion)
      end
      boolean :enabled, default: true
      string :category, required: true do
        enum %w(started_discussions followed_discussions)
      end
    end
  end

  def update
    root do
      additional_properties false
      boolean :enabled, required: true
    end
  end
end
