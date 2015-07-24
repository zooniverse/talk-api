module JSON::SchemaBuilder::RSpecHelper
  let(:id_schema) do
    {
      oneOf: [
        { 'type' => 'integer', 'minimum' => 1 },
        { 'type' => 'string', 'pattern' => '^[1-9]\d*$' }
      ]
    }
  end
  let(:nullable_id_schema) do
    {
      oneOf: [
        { 'type' => 'integer', 'minimum' => 1 },
        { 'type' => 'string', 'pattern' => '^[1-9]\d*$' },
        { 'type' => 'null' }
      ]
    }
  end
end
