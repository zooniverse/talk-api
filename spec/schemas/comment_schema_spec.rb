require 'spec_helper'

RSpec.describe CommentSchema, type: :schema do
  shared_examples_for 'a comment schema' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['comments'] }
    
    with :properties do
      with :comments do
        its(:type){ is_expected.to eql 'object' }
        its(:additionalProperties){ is_expected.to be false }
        
        with :properties do
          its(:category){ is_expected.to eql type: 'string' }
          its(:body){ is_expected.to eql type: 'string' }
          its(:focus_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }, { 'type' => 'null' }] }
          its(:focus_type){ is_expected.to eql enum: %w(Subject Collection) }
        end
      end
    end
  end
  
  describe '#create' do
    let(:schema_method){ :create }
    it_behaves_like 'a comment schema'
    
    with 'properties .comments' do
      its(:required){ is_expected.to eql %w(user_id body discussion_id) }
      
      with 'properties' do
        its(:user_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }] }
        its(:discussion_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }] }
      end
    end
  end
  
  describe '#update' do
    context 'when moveable' do
      let(:schema_method){ :update }
      let(:record){ create :comment }
      let(:user){ record.user }
      let(:schema_context){ { policy: CommentPolicy.new(user, record) } }
      it_behaves_like 'a comment schema'
      
      with 'properties .comments' do
        with 'properties' do
          its(:discussion_id){ is_expected.to eql oneOf: [{ 'type' => 'string' }, { 'type' => 'integer' }] }
        end
      end
    end
    
    context 'when not moveable' do
      let(:schema_method){ :update }
      let(:record){ create :comment }
      let(:user){ create :user }
      let(:schema_context){ { policy: CommentPolicy.new(user, record) } }
      it_behaves_like 'a comment schema'
      
      with 'properties .comments' do
        with 'properties' do
          its(:discussion_id){ is_expected.to be nil }
        end
      end
    end
  end
end
