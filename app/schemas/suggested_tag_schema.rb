class SuggestedTagSchema
  include JSON::SchemaBuilder

  root :suggested_tags

  def create
    changes required: true
  end

  def update
    changes
  end

  def changes(required = { })
    root do
      additional_properties false
      string :name, **required
      string :section, **required
    end
  end
end
