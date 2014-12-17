require 'spec_helper'

RSpec.describe BoardSchema, type: :schema do
  describe '#create' do
    it_behaves_like 'a schema', :create do
      let(:expected_json) do
        {
          type: :object,
          required: [:boards],
          properties: {
            boards: {
              type: :object,
              required: [:title, :description],
              properties: {
                title: { type: :string },
                description: { type: :string },
                section: { type: :string }
              }
            }
          }
        }
      end
    end
  end
  
  describe '#update' do
    it_behaves_like 'a schema', :update do
      let(:expected_json) do
        {
          type: :object,
          required: [:boards],
          properties: {
            boards: {
              type: :object,
              required: [:title, :description],
              properties: {
                title: { type: :string },
                description: { type: :string }
              }
            }
          }
        }
      end
    end
  end
end
