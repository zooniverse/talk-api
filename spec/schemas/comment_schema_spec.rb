require 'spec_helper'

RSpec.describe CommentSchema, type: :schema do
  describe '#create' do
    it_behaves_like 'a schema', :create do
      let(:expected_json) do
        {
          type: :object,
          required: [:comments],
          properties: {
            comments: {
              type: :object,
              required: [:body, :discussion_id],
              properties: {
                category: { type: :string },
                body: { type: :string },
                focus_id: { type: :integer },
                discussion_id: { type: :integer }
              }
            }
          }
        }
      end
    end
  end
  
  describe '#update' do
    context 'when moveable' do
      it_behaves_like 'a schema', :update do
        let(:record){ create :comment }
        let(:user){ record.user }
        let(:schema_context){ { policy: CommentPolicy.new(user, record) } }
        let(:expected_json) do
          {
            type: :object,
            required: [:comments],
            properties: {
              comments: {
                type: :object,
                required: [:body, :discussion_id],
                properties: {
                  category: { type: :string },
                  body: { type: :string },
                  focus_id: { type: :integer },
                  discussion_id: { type: :integer }
                }
              }
            }
          }
        end
      end
    end
    
    context 'when not moveable' do
      it_behaves_like 'a schema', :update do
        let(:record){ create :comment }
        let(:user){ create :user }
        let(:schema_context){ { policy: CommentPolicy.new(user, record) } }
        let(:expected_json) do
          {
            type: :object,
            required: [:comments],
            properties: {
              comments: {
                type: :object,
                required: [:body],
                properties: {
                  category: { type: :string },
                  body: { type: :string },
                  focus_id: { type: :integer }
                }
              }
            }
          }
        end
      end
    end
  end
end
