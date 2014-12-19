JSON::SchemaBuilder.configure do |opts|
  opts.insert_defaults = true
  opts.errors_as_objects = true
  opts.validate_schema = true if Rails.env.development? || Rails.env.test?
end
