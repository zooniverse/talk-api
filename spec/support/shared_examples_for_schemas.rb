require 'spec_helper'

RSpec.shared_examples_for 'a schema' do |method_name|
  let(:schema_context){ { } }
  let(:schema){ described_class.new(schema_context).send method_name }
  let(:json){ schema.as_json }
  let(:expected_json){ { } }
  
  it 'should return an entity' do
    expect(schema).to be_a JSON::SchemaBuilder::Entity
  end
  
  it 'should produce the correct json schema' do
    expect(json).to eql expected_json.as_json
  end
end
